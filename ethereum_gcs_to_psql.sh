#set -o xtrace

usage() { echo "Usage: $0 <input_bucket> <psql_url>" 1>&2; exit 1; }

input_bucket=$1
psql_url=$2

if [ -z "${input_bucket}" ] || [ -z "${psql_url}" ]; then
    usage
fi

declare -a tables=(
  "block"
  "transaction"
  "token_transfer"
  "trace"
  "log"
  "contract"
  "token"
)

declare -a column_names
column_names["block"]="(timestamp,number,hash,parent_hash,nonce,sha3_uncles,logs_bloom,transactions_root,state_root,receipts_root,miner,difficulty,total_difficulty,size,extra_data,gas_limit,gas_used,transaction_count,base_fee_per_gas)"
column_names["transaction"]="(hash,nonce,transaction_index,from_address,to_address,value,gas,gas_price,input,receipt_cumulative_gas_used,receipt_gas_used,receipt_contract_address,receipt_root,receipt_status,block_timestamp,block_number,block_hash,max_fee_per_gas,max_priority_fee_per_gas,transaction_type,receipt_effective_gas_price)"
column_names["token_transfer"]="value3"
column_names["trace"]="(transaction_hash,transaction_index,from_address,to_address,value,input,output,trace_type,call_type,reward_type,gas,gas_used,subtraces,trace_address,error,status,block_timestamp,block_number,block_hash,trace_id)"
column_names["log"]="value4"
column_names["contract"]="(transaction_hash,transaction_index,from_address,to_address,value,input,output,trace_type,call_type,reward_type,gas,gas_used,subtraces,trace_address,error,status,block_timestamp,block_number,block_hash,trace_id)"
column_names["token"]="value5"

# TODO: validate table names and column before moving forward

for table in "${tables[@]}"
do
    folder="bigquery_public_data_crypto_ethereum_${table}s_fitered"
    uri="gs://${input_bucket}/${folder}"
    echo "Importing files from ${uri}"
    bash gcs_to_psql.sh ${uri} ${psql_url} ${table}
done
