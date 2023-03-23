echo "Executing: export BUCKET=axel-ethereum_data-csv"
export BUCKET=axel-ethereum_data-csv
echo "Executing: sh ethereum_bigquery_to_gcs.sh $BUCKET"
gcloud config set project regal-skyline-379801
sh ethereum_bigquery_to_gcs.sh $BUCKET 2023-03-01 2023-03-02