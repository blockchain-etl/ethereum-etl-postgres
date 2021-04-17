#set -o xtrace

usage() { echo "Usage: $0 <input_gcs_uri> <cloud_sql_instance_id> <table_name>" 1>&2; exit 1; }

input_gcs_uri=$1
cloud_sql_instance_id=$2
table_name=$3

if [ -z "${input_gcs_uri}" ] || [ -z "${cloud_sql_instance_id}" ] || [ -z "${table_name}" ]; then
    usage
fi

database_name="ethereum"

for gcs_file in $(gsutil ls ${input_gcs_uri}); do
    command="gcloud sql import csv ${cloud_sql_instance_id} ${gcs_file} --database=${database_name} --table=${table_name} --quiet --async"
    echo "Executing command ${command}"
    operation_url=$(${command})
    operation_id="${operation_url: -36}"
    gcloud sql operations wait --project crypto-etl-ethereum-dev ${operation_id} --timeout unlimited
    sleep 10
done