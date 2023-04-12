# Ethereum ETL for PostgreSQL

The steps below will allow you to bootstrap a PostgreSQL database in GCP with full historical and real-time Ethereum data:
blocks, transactions, logs, token_transfers, and traces.

The whole process will take between 24 and 72 hours.

**Prerequisites**:

- Python 3.6+
- gcloud
- psql
- [Cloud SQL Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy#install)

### 1. Export Ethereum data from BigQuery to CSV files in GCS

- Install gcloud and run `gcloud auth login`
- Run 
```bash
pip install -r requirements.txt
# bucket link: https://console.cloud.google.com/storage/browser/axel-ethereum_data-csv
export BUCKET=axel-ethereum_data-csv
sh ethereum_bigquery_to_gcs.sh $BUCKET 2020-01-01 2020-01-02
```

If you want to download everything, ignore the start and end dates: `bash ethereum_bigquery_to_gcs.sh $BUCKET`
Exporting to CSV files on GCS is going to take about 10 minutes.

### 2. Import data from CSV files to PostgreSQL database in Cloud SQL

- Create a new Cloud SQL instance IF we don't have one
```bash
  gcloud sql instances list # check for binocular-server
```

```bash
# only run this if it doesn't already exist
export CLOUD_SQL_INSTANCE_ID=binocular-server
export ROOT_PASSWORD=<your_password> # pull from 1password Cloud SQL DB - Binocular Server
gcloud sql instances create $CLOUD_SQL_INSTANCE_ID --database-version=POSTGRES_11 --root-password=$ROOT_PASSWORD \
    --storage-type=SSD --storage-size=100 --cpu=4 --memory=6 \
    --database-flags=temp_file_limit=2147483647
```

Notice the storage size is set to 100 GB. It will scale up automatically to around 1.5 TB when we load in the data.

- Add Cloud SQL service account to GCS bucket as `objectViewer`. 
Run `gcloud sql instances describe $CLOUD_SQL_INSTANCE_ID`,
then copy `serviceAccountEmailAddress` from the output and add it to the bucket.

- Create the database and the tables:

```bash
export CLOUD_SQL_INSTANCE_ID=binocular-server
# gcloud sql databases create postgres --instance=$CLOUD_SQL_INSTANCE_ID

# Install Cloud SQL Proxy following the instructions here https://cloud.google.com/sql/docs/mysql/sql-proxy#install
./cloud-sql-proxy regal-skyline-379801:us-central1:${CLOUD_SQL_INSTANCE_ID}

cat schema/*.sql | psql -U postgres -d postgres -h 127.0.0.1 -a
```

- Run import from GCS to Cloud SQL:

```bash
echo $BUCKET $CLOUD_SQL_INSTANCE_ID
sh ethereum_gcs_to_cloud_sql.sh $BUCKET $CLOUD_SQL_INSTANCE_ID
```

Importing to Cloud SQL is going to take between 12 and 24 hours.

A few performance optimization tips for initial loading of the data:

- Turn off fsync https://www.postgresql.org/docs/11/runtime-config-wal.html.
- Use UNLOGGED tables.
- Turn OFF auto backups and vacuum on Google Cloud SQL instance.

### 3. Apply indexes to the tables

NOTE: indexes won't work for the contracts table due to the issue described here https://github.com/blockchain-etl/ethereum-etl-postgres/pull/11#issuecomment-1107801061

- Run:

```bash
cat indexes/*.sql | psql -U postgres -d postgres -h 127.0.0.1 -a
```

Creating indexes is going to take between 12 and 24 hours. Depending on the queries you're going to run
you may need to create more indexes or [partition](https://www.postgresql.org/docs/11/ddl-partitioning.html) the tables.

Cloud SQL instance will cost you between $200 and $500 per month depending on 
whether you use HDD or SSD and on the machine type. 

### 4. Streaming

Use `ethereumetl stream` command to continually pull data from an Ethereum node and insert it to Postgres tables:
https://github.com/blockchain-etl/ethereum-etl/tree/develop/docs/commands.md#stream.

Follow the instructions here to deploy it to Kubernetes: https://github.com/blockchain-etl/blockchain-etl-streaming.