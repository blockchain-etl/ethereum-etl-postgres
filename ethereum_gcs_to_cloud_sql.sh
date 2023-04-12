#set -o xtrace

usage() { echo "Usage: $0 <input_bucket> <cloud_sql_instance_id>" 1>&2; exit 1; }

input_bucket=$1
cloud_sql_instance_id=$2

if [ -z "${input_bucket}" ] || [ -z "${cloud_sql_instance_id}" ]; then
    usage
fi

declare -a tables=(
    "blocks"
    "transactions"
    "token_transfers"
    "traces"
    "logs"
    "contracts"
    "tokens"
)

for table in "${tables[@]}"
do
    folder="bigquery-public-data:crypto_ethereum.${table}"
    uri="gs://${input_bucket}/${folder}"
    # Wayland: I tried creating a mapping for 1 hour and couldn't do it so just gonna resort to if else
    if [ "$table" == "blocks" ]; then
        table_type="block"
    elif [ "$table" == "transactions" ]; then
        table_type="transaction"
    elif [ "$table" == "traces" ]; then
        table_type="trace"
    elif [ "$table" == "token_transfers" ]; then
        table_type="token_transfer"
    elif [ "$table" == "logs" ]; then
        table_type="log"
    elif [ "$table" == "contracts" ]; then
        table_type="contract"
    elif [ "$table" == "tokens" ]; then
        table_type="token"
    else
        echo "Unknown table type for $table"
        exit 1
    fi
    
    echo "Importing files from ${uri} to ${cloud_sql_instance_id} $table_type"
    sh gcs_to_cloud_sql.sh ${uri} ${cloud_sql_instance_id} ${table_type}
done
