# Ethereum ETL for PostgreSQL

The steps below will allow you to bootstrap a PostgreSQL database in GCP with full historical and real-time Ethereum data:
blocks, transactions, logs, token_transfers, and traces.

The whole process will take between 24 and 72 hours.

**Prerequisites**:

- Python 3.6+
- gcloud

### 1. Export Ethereum data from BigQuery to CSV files in GCS

- Install gcloud and run `gcloud auth login`
- Run 
```bash
pip install -r requirements.txt
export BUCKET=<your_gcs_bucket>
bash ethereum_bigquery_to_gcs.sh $BUCKET
```

Optionally provide start and end dates: `bash ethereum_bigquery_to_gcs.sh $BUCKET 2020-01-01 2020-01-31`

Exporting to CSV files is going to take about 10 minutes.

### 2. Import data from CSV files to PostgreSQL database in Cloud SQL

- Create a new Cloud SQL instance 

```bash
export CLOUD_SQL_INSTANCE_ID=ethereum-0
export ROOT_PASSWORD=<your_password>
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
gcloud sql databases create ethereum --instance=$CLOUD_SQL_INSTANCE_ID

# Install Cloud SQL Proxy following the instrucitons here https://cloud.google.com/sql/docs/mysql/sql-proxy#install
./cloud_sql_proxy -instances=myProject:us-central1:${CLOUD_SQL_INSTANCE_ID}=tcp:5433

cat schema/*.sql | psql -U postgres -d ethereum -h 127.0.0.1  --port 5433 -a
```

- Run import from GCS to Cloud SQL:

```bash
bash ethereum_gcs_to_cloud_sql.sh $BUCKET $CLOUD_SQL_INSTANCE_ID
```

Importing to Cloud SQL is going to take between 12 and 24 hours.

A few performance optimization tips for initial loading of the data:

- Turn off fsync https://www.postgresql.org/docs/11/runtime-config-wal.html.
- Use UNLOGGED tables.
- Turn OFF auto backups and vacuum on Google Cloud SQL instance.

### 3. Apply indexes to the tables

- Run:

```bash
cat indexes/*.sql | psql -U postgres -d ethereum -h 127.0.0.1  --port 5433 -a
```

Creating indexes is going to take between 12 and 24 hours. Depending on the queries you're going to run
you may need to create more indexes or [partition](https://www.postgresql.org/docs/11/ddl-partitioning.html) the tables.

Cloud SQL instance will cost you between $200 and $500 per month depending on 
whether you use HDD or SSD and on the machine type. 

### 4. Streaming

Use `ethereumetl stream` command to continually pull data from an Ethereum node and insert it to Postgres tables:
https://github.com/blockchain-etl/ethereum-etl/tree/develop/docs/commands.md#stream.

Follow the instructions here to deploy it to Kubernetes: https://github.com/blockchain-etl/blockchain-etl-streaming.