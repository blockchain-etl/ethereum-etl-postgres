#set -o xtrace

usage() { echo "Usage: $0 <input_table> <output_bucket>" 1>&2; exit 1; }

input_table=$1
output_bucket=$2

if [ -z "${input_table}" ] || [ -z "${output_bucket}" ]; then
    usage
fi

output_folder="${input_table}"
output_folder_raw="${output_folder}_raw"
output_folder_composed="${output_folder}_composed"

output_uri="gs://${output_bucket}/${output_folder_raw}/*.gz"
echo "Extracting ${input_table} to ${output_uri} ..."
bq extract --noprint_header --compression=GZIP --destination_format=CSV ${input_table} ${output_uri}

python ethereumetl_postgres/gcs_compose.py -b ${output_bucket} -i "${output_folder_raw}/" -o "${output_folder_composed}/"
python ethereumetl_postgres/gcs_compose.py -b ${output_bucket} -i "${output_folder_composed}/" -o "${output_folder}/"

gsutil -m rm -r "gs://${output_bucket}/${output_folder_raw}"
gsutil -m rm -r "gs://${output_bucket}/${output_folder_composed}"