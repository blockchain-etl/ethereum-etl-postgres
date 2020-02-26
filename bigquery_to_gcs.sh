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

# BigQuery exports partitioned tables to many small files. We combine them to bigger files to import faster.
python ethereumetl_postgresql/gcs_compose.py -b ${output_bucket} -i "${output_folder_raw}/" -o "${output_folder_composed}/"
# gcloud compose has limit of 32 files in one compose operation. Try composing once more to work around this limit.
python ethereumetl_postgresql/gcs_compose.py -b ${output_bucket} -i "${output_folder_composed}/" -o "${output_folder}/"

# Cleanup

gsutil -m rm -r "gs://${output_bucket}/${output_folder_raw}"
gsutil -m rm -r "gs://${output_bucket}/${output_folder_composed}"