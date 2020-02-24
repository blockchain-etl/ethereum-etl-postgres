#set -o xtrace

usage() { echo "Usage: $0 <output_bucket>" 1>&2; exit 1; }

output_bucket=$1

if [ -z "${output_bucket}" ]; then
    usage
fi

## declare an array variable
declare -a tables=(
    'bigquery-public-data:crypto_ethereum.blocks'
    'bigquery-public-data:crypto_ethereum.transactions'
    'bigquery-public-data:crypto_ethereum.token_transfers'
    'bigquery-public-data:crypto_ethereum.traces'
)

for table in "${tables[@]}"
do
   echo "Exporting ${table}"
   bash export_bigquery_to_gcs.sh ${table} ${output_bucket}
done
