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
    echo "Importing files from ${uri}"
    bash gcs_to_cloud_sql.sh ${uri} ${cloud_sql_instance_id} ${table}
done
