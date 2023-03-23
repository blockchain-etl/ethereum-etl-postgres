#set -o xtrace

usage() { echo "Usage: $0 <output_bucket>" 1>&2; exit 1; }

output_bucket=$1

if [ -z "${output_bucket}" ]; then
    usage
fi

start_date=$2
end_date=$3
filter_date=false
if [ -n "${start_date}" ] && [ -n "${end_date}" ]; then
    filter_date=true
fi

# The logs and contracts tables contain columns with type ARRAY<STRING>. 
# BigQuery can't export it to CSV so we need to flatten it.
if [ "${filter_date}" = "true" ]; then
  export_temp_dataset="export_temp_dataset_${start_date}_to_${end_date}"
else
  export_temp_dataset="export_temp_dataset"
fi
export_temp_logs_table="flattened_logs"
export_temp_contracts_table="flattened_contracts"

bq rm -r -f ${export_temp_dataset}
bq mk ${export_temp_dataset}

# Use awk to trim comments in sql files.
flatten_crypto_ethereum_logs_sql=$(cat ./flatten_crypto_ethereum_logs.sql | awk -F '--' '{print $1}'| tr '\n' ' ')
flatten_crypto_ethereum_contracts_sql=$(cat ./flatten_crypto_ethereum_contracts.sql | awk -F '--' '{print $1}' |  tr '\n' ' ')

if [ "${filter_date}" = "true" ]; then
    flatten_crypto_ethereum_logs_sql="${flatten_crypto_ethereum_logs_sql} where date(block_timestamp) >= '${start_date}' and date(block_timestamp) <= '${end_date}'"
    flatten_crypto_ethereum_contracts_sql="${flatten_crypto_ethereum_contracts_sql} where date(block_timestamp) >= '${start_date}' and date(block_timestamp) <= '${end_date}'"
fi

echo "Executing query ${flatten_crypto_ethereum_logs_sql}"
bq --location=US query --destination_table ${export_temp_dataset}.${export_temp_logs_table} --use_legacy_sql=false "${flatten_crypto_ethereum_logs_sql}"
echo "Executing query ${flatten_crypto_ethereum_contracts_sql}"
bq --location=US query --destination_table ${export_temp_dataset}.${export_temp_contracts_table} --use_legacy_sql=false "${flatten_crypto_ethereum_contracts_sql}"

declare -a tables=(
    "bigquery-public-data:crypto_ethereum.blocks"
    "bigquery-public-data:crypto_ethereum.transactions"
    "bigquery-public-data:crypto_ethereum.token_transfers"
    "bigquery-public-data:crypto_ethereum.traces"
    "bigquery-public-data:crypto_ethereum.tokens"
    "${export_temp_dataset}.${export_temp_logs_table}"
    "${export_temp_dataset}.${export_temp_contracts_table}"
)

for table in "${tables[@]}"
do
    echo "Exporting BigQuery table ${table}"
    if [ "${filter_date}" = "true" ]; then
        query="select * from \`${table//:/.}\`"
        timestamp_column="block_timestamp"
        if [ "${table}" = "bigquery-public-data:crypto_ethereum.blocks" ]; then
            timestamp_column="timestamp"
        fi
        query="${query} where date(${timestamp_column}) >= '${start_date}' and date(${timestamp_column}) <= '${end_date}'"
        fitered_table_name="${table//[.:-]/_}_fitered"
        echo "Executing query ${query} and saving it in our BigQuery instance"
        bq --location=US query --destination_table "${export_temp_dataset}.${fitered_table_name}" --use_legacy_sql=false "${query}"

        output_folder=${fitered_table_name}
        echo "Moving data from our BigQuery instance to Google Cloud Storage"
        bash bigquery_to_gcs.sh "${export_temp_dataset}.${fitered_table_name}" ${output_bucket} ${output_folder}
        gsutil -m mv gs://${output_bucket}/${output_folder}/* gs://${output_bucket}/${table}/
    else
        output_folder=${table}
        bash bigquery_to_gcs.sh ${table} ${output_bucket} ${output_folder}
    fi
done

# Rename output folder for flattened tables
gsutil -m mv gs://${output_bucket}/${export_temp_dataset}.${export_temp_logs_table}/* gs://${output_bucket}/bigquery-public-data:crypto_ethereum.logs/
gsutil -m mv gs://${output_bucket}/${export_temp_dataset}.${export_temp_contracts_table}/* gs://${output_bucket}/bigquery-public-data:crypto_ethereum.contracts/

# Cleanup
bq rm -r -f ${export_temp_dataset}
