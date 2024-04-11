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
export_temp_dataset="export_temp_dataset"
export_temp_blocks_table="flattened_blocks"
export_temp_transactions_table="flattened_transactions"
export_temp_logs_table="flattened_logs"
export_temp_contracts_table="flattened_contracts"

bq rm -r -f ${export_temp_dataset}
bq mk ${export_temp_dataset}

flatten_table() {
    local sql_file=$1
    local temp_table_name=$2
    local timestamp_column=$3
    local sql=$(cat ./${sql_file} | awk -F '--' '{print $1}'| tr '\n' ' ')

    if [ "${filter_date}" = "true" ]; then
        sql="${sql} where date(${timestamp_column}) >= '${start_date}' and date(${timestamp_column}) <= '${end_date}'"
    fi

    echo "Executing query ${sql}"
    bq --location=US query --destination_table ${export_temp_dataset}.${temp_table_name} --use_legacy_sql=false "${sql}"
}

flatten_table "flatten_crypto_ethereum_blocks.sql" "${export_temp_blocks_table}" "timestamp"
flatten_table "flatten_crypto_ethereum_transactions.sql" "${export_temp_transactions_table}" "block_timestamp"
flatten_table "flatten_crypto_ethereum_logs.sql" "${export_temp_logs_table}" "block_timestamp"
flatten_table "flatten_crypto_ethereum_contracts.sql" "${export_temp_contracts_table}" "block_timestamp"

declare -a tables=(
    "${export_temp_dataset}.${export_temp_blocks_table}"
    "${export_temp_dataset}.${export_temp_transactions_table}"
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
        if [ "${table}" = "${export_temp_dataset}.${export_temp_blocks_table}" ]; then
            timestamp_column="timestamp"
        fi
        query="${query} where date(${timestamp_column}) >= '${start_date}' and date(${timestamp_column}) <= '${end_date}'"
        filtered_table_name="${table//[.:-]/_}_filtered"
        echo "Executing query ${query}"
        bq --location=US query --destination_table "${export_temp_dataset}.${filtered_table_name}" --use_legacy_sql=false "${query}"

        output_folder=${filtered_table_name}
        bash bigquery_to_gcs.sh "${export_temp_dataset}.${filtered_table_name}" ${output_bucket} ${output_folder}
        gsutil -m mv gs://${output_bucket}/${output_folder}/* gs://${output_bucket}/${table}/
    else
        output_folder=${table}
        bash bigquery_to_gcs.sh ${table} ${output_bucket} ${output_folder}
    fi
done

# Rename output folder for flattened tables
gsutil -m mv gs://${output_bucket}/${export_temp_dataset}.${export_temp_blocks_table}/* gs://${output_bucket}/bigquery-public-data:crypto_ethereum.blocks/
gsutil -m mv gs://${output_bucket}/${export_temp_dataset}.${export_temp_transactions_table}/* gs://${output_bucket}/bigquery-public-data:crypto_ethereum.transactions/
gsutil -m mv gs://${output_bucket}/${export_temp_dataset}.${export_temp_logs_table}/* gs://${output_bucket}/bigquery-public-data:crypto_ethereum.logs/
gsutil -m mv gs://${output_bucket}/${export_temp_dataset}.${export_temp_contracts_table}/* gs://${output_bucket}/bigquery-public-data:crypto_ethereum.contracts/

# Cleanup
bq rm -r -f ${export_temp_dataset}
