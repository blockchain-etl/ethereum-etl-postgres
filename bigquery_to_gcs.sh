#set -o xtrace

usage() { echo "Usage: $0 <input_table> <output_bucket> [<folder>]" 1>&2; exit 1; }

# Read input params

input_table=$1
output_bucket=$2

if [ -z "${input_table}" ] || [ -z "${output_bucket}" ]; then
    usage
fi

output_folder=$3
if [ -z "${output_folder}" ]; then
    output_folder="${input_table}"
fi

# Call bq extract

output_folder_raw="${output_folder}_raw"
output_folder_composed="${output_folder}_composed"

output_uri="gs://${output_bucket}/${output_folder_raw}/*.gz"
echo "Extracting ${input_table} to ${output_uri} ..."
bq extract --noprint_header --destination_format=CSV --compression=GZIP ${input_table} ${output_uri}

# TODO: Update it to handle python and python3 - aliases don't work in bash scripts, so you should detect what python is available
# BigQuery exports partitioned tables to many small files. We combine them to bigger files to import faster.
echo "Combine BigQuery exports to bigger files so we that we can import faster."

output=$(python3 ethereumetl_postgres/gcs_compose.py -b ${output_bucket} -i "${output_folder_raw}/" -o "${output_folder_composed}/" 2>&1 | tee /dev/tty)
if [[ $output =~ "OSError: Project was not passed and could not be determined from the environment." ]]; then
    echo -e "-e \"\033[1;37;41mERROR:\033[0m Please set your project using the following command: gcloud config set project _project_name_"
    exit 1
fi
# gcloud compose has limit of 32 files in one compose operation. Try composing once more to work around this limit.
python3 ethereumetl_postgres/gcs_compose.py -b ${output_bucket} -i "${output_folder_composed}/" -o "${output_folder}/"

# Cleanup
echo "Cleaning up the raw and composed folders from the Google Cloud Bucket"
gsutil -m rm -r "gs://${output_bucket}/${output_folder_raw}"
gsutil -m rm -r "gs://${output_bucket}/${output_folder_composed}"
