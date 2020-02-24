set -o xtrace

for (( partition=0; partition <= 53; partition+=1 )); do
    padded_partition=`printf "%012d" ${partition}`
    imported_file="gs://ethereum-cloudsql-import/transactions_combined/${padded_partition}.gz"
    command="gcloud sql import csv ethereum-0 ${imported_file} --database=ethereum --table=transactions --quiet --async"
    operation_url=$(${command})
    operation_id="${operation_url: -36}"
    gcloud sql operations wait --project crypto-etl-ethereum-dev ${operation_id} --timeout unlimited
    sleep 5
done