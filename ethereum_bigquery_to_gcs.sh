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

# The log and contract tables contain columns with type ARRAY<STRING>. 
# BigQuery can't export it to CSV so we need to flatten it.
if [ "${filter_date}" = "true" ]; then
  export_temp_dataset="export_temp_dataset_${start_date//-/_}_to_${end_date//-/_}"
else
  export_temp_dataset="export_temp_dataset"
fi
export_temp_log_table="flattened_log"
export_temp_contract_table="flattened_contract"

bq rm -r -f ${export_temp_dataset}
bq mk ${export_temp_dataset}

# Use awk to trim comments in sql files.
flatten_crypto_ethereum_log_sql=$(cat ./flatten_crypto_ethereum_logs.sql | awk -F '--' '{print $1}'| tr '\n' ' ')
flatten_crypto_ethereum_contract_sql=$(cat ./flatten_crypto_ethereum_contracts.sql | awk -F '--' '{print $1}' |  tr '\n' ' ')

if [ "${filter_date}" = "true" ]; then
    flatten_crypto_ethereum_log_sql="${flatten_crypto_ethereum_log_sql} where date(block_timestamp) >= '${start_date}' and date(block_timestamp) <= '${end_date}'"
    flatten_crypto_ethereum_contract_sql="${flatten_crypto_ethereum_contract_sql} where date(block_timestamp) >= '${start_date}' and date(block_timestamp) <= '${end_date}'"
fi

echo "Executing query ${flatten_crypto_ethereum_log_sql}"
bq --location=US query --destination_table ${export_temp_dataset}.${export_temp_log_table} --use_legacy_sql=false "${flatten_crypto_ethereum_log_sql}"
echo "Executing query ${flatten_crypto_ethereum_contract_sql}"
bq --location=US query --destination_table ${export_temp_dataset}.${export_temp_contract_table} --use_legacy_sql=false "${flatten_crypto_ethereum_contract_sql}"

declare -a tables=(
    "bigquery-public-data:crypto_ethereum.blocks"
    "bigquery-public-data:crypto_ethereum.transactions"
    "bigquery-public-data:crypto_ethereum.token_transfers"
    "bigquery-public-data:crypto_ethereum.traces"
    "bigquery-public-data:crypto_ethereum.tokens"
    "${export_temp_dataset}.${export_temp_log_table}"
    "${export_temp_dataset}.${export_temp_contract_table}"
)

for table in "${tables[@]}"
do
    echo "Exporting BigQuery table ${table}"
    if [ "${filter_date}" = "true" ]; then
        query="select * from \`${table//:/.}\`"
        timestamp_column="block_timestamp"
        if [ "${table}" = "bigquery-public-data:crypto_ethereum.blocks" ]; then
            timestamp_column="timestamp"
            # temp fix b/c bigquery added a nested column called withdrawals
            # in the future we should only query for data that we are storing, while staying on top of any new columns that are added
            block_columns="timestamp,number,h.hash,parent_hash,nonce,sha3_uncles,logs_bloom,transactions_root,state_root,receipts_root,miner,difficulty,total_difficulty,size,extra_data,gas_limit,gas_used,transaction_count,base_fee_per_gas"
            query="select ${block_columns} from \`${table//:/.}\` h"
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
gsutil -m mv gs://${output_bucket}/${export_temp_dataset}.${export_temp_log_table}/* gs://${output_bucket}/bigquery-public-data:crypto_ethereum.logs/
gsutil -m mv gs://${output_bucket}/${export_temp_dataset}.${export_temp_contract_table}/* gs://${output_bucket}/bigquery-public-data:crypto_ethereum.contracts/

# Cleanup
bq rm -r -f ${export_temp_dataset}
