#set -o xtrace

for file in $(gsutil ls gs://ethereum-cloudsql-import/bigquery-public-data:crypto_ethereum.blocks); do
    echo "Test ${file}"
done