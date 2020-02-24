#set -o xtrace

usage() { echo "Usage: $0 <output_bucket>" 1>&2; exit 1; }

output_bucket=$1

if [ -z "${output_bucket}" ]; then
    usage
fi

# The logs table has topics column with type ARRAY<STRING>. BigQuery can't export it to CSV so we need to flatten it.
export_temp_dataset="export_temp_dataset"
export_temp_logs_table="flattened_logs"
bq mk ${export_temp_dataset}
bq --location=US query --destination_table ${export_temp_dataset}.${export_temp_logs_table} --use_legacy_sql=false "$(cat ./flatten_crypto_ethereum_logs.sql | tr '\n' ' ')"

declare -a tables=(
    "bigquery-public-data:crypto_ethereum.blocks"
    "bigquery-public-data:crypto_ethereum.transactions"
    "bigquery-public-data:crypto_ethereum.token_transfers"
    "bigquery-public-data:crypto_ethereum.traces"
    "${export_temp_dataset}.${export_temp_logs_table}"
)

for table in "${tables[@]}"
do
    echo "Exporting BigQuery table ${table}"
    output_folder=${table}
    bash export_bigquery_to_gcs.sh ${table} ${output_bucket} ${output_folder}
done

# Rename output folder for flattened logs
gsutil -m mv gs://${output_bucket}/${export_temp_dataset}.${export_temp_logs_table}/* gs://${output_bucket}/bigquery-public-data:crypto_ethereum.logs

# Cleanup
bq rm -r -f ${export_temp_dataset}
