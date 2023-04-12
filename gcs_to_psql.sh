#set -o xtrace

usage() { echo "Usage: $0 <input_gcs_uri> <psql_url> <table_name>" 1>&2; exit 1; }

input_gcs_uri=$1
psql_url=$2
table_name=$3
database_name=$4

if [ -z "${input_gcs_uri}" ] || [ -z "${psql_url}" ] || [ -z "${table_name}" ]; then
    usage
fi

for gcs_file in $(gsutil ls ${input_gcs_uri}); do
    command="psql $DATABASE_URL -c \"\copy \"${table_name}\" FROM '/Users/waylandhe/git/ethereum-etl-postgres/bigquery_public_data_crypto_ethereum_block_fitered.csv' DELIMITER ',' CSV HEADER\""

    # command="psql ${psql_url} -c table_name${gcs_file} --database=${database_name} --table=${table_name} --quiet --async"
    echo "Executing command ${command}"
    # operation_url=$(${command})
    # operation_id="${operation_url: -36}"
    # gcloud sql operations wait ${operation_id} --timeout unlimited
    sleep 10
done
