# Ethereum ETL PostgreSQL

To export Ethereum data to CSV files:

- Install gcloud
- Run `gcloud auth login`
- Run `pip install -r requirements.txt`
- Run `ethereum_export_bigquery_to_gcs.sh <your_gcs_bucket>`

TODO:

Postgres config:

temp_file_limit: 2147483647

Add Cloud SQL service account to the bucket.

Create database.