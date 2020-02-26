# Ethereum ETL for PostgreSQL

### Export Ethereum data from BigQuery to CSV files in GCS

- Install gcloud and run `gcloud auth login`
- Run `pip install -r requirements.txt`
- Run `ethereum_bigquery_to_gcs.sh $BUCKET`

Exporting to CSV files is going to take about 10 minutes.

### Import data from CSV files to PostgreSQL database in Cloud SQL

- Create a new Cloud SQL instance 

```bash
export CLOUD_SQL_INSTANCE_ID=ethereum-0
gcloud sql instances create $CLOUD_SQL_INSTANCE_ID --database-version=POSTGRES_11 --root-password=<your_password> \
    --storage-type=SSD --storage-size=100 --cpu=4 --memory=6 \
    --database-flags=temp_file_limit=2147483647
```

Notice the storage size is set to 100GB. It will scale up automatically when we load in the data.

- Add Cloud SQL service account to GCS bucket as `objectViewer`:

```bash
gcloud sql instances describe $CLOUD_SQL_INSTANCE_ID
```

Copy serviceAccountEmailAddress from the output and add to the bucket

- Create database and tables:

```bash
gcloud sql databases create ethereum --instance=$CLOUD_SQL_INSTANCE_ID

# Install Cloud SQL Proxy following the instrucitons here https://cloud.google.com/sql/docs/mysql/sql-proxy#install
./cloud_sql_proxy -instances=myProject:us-central1:${CLOUD_SQL_INSTANCE_ID}=tcp:5432

cat schema/*.sql | psql -U postgres -d ethereum -h 127.0.0.1  --port 5433 -a
```

- Run import from GCS to Cloud SQL:

```bash
bash ethereum_gcs_to_cloud_sql.sh $BUCKET $CLOUD_SQL_INSTANCE_ID
```

Importing to Cloud SQL is going to take between 12 and 24 hours.

### Apply indexes to the tables

- Run:

```bash
cat indexes/*.sql | psql -U postgres -d ethereum -h 127.0.0.1  --port 5433 -a
```

Creating indexes is going to take between 12 and 24 hours. Depending on the queries you're going to run
you may need to create more indexes or partition the tables.

Cloud SQL instance will cost you between $200 and $500 per month depending on 
whether you use HDD or SSD and on the machine type. 

