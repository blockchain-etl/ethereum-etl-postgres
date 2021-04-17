import argparse

from google.cloud import storage

BYTES_IN_GB = 10 ** 9
GCS_MAX_FILE_SIZE = 2 * BYTES_IN_GB
GCS_MAX_FILES_FOR_COMBINE = 32

parser = argparse.ArgumentParser(description='Compose files in GCS folder.')
parser.add_argument('-b', '--bucket', required=True, type=str, help='Bucket name.')
parser.add_argument('-i', '--input-folder', required=True, type=str, help='Input folder.')
parser.add_argument('-o', '--output-folder', required=True, type=str, help='Output folder.')
parser.add_argument('-m', '--max-size-in-bytes', default=GCS_MAX_FILE_SIZE, type=str,
                    help='Maximum size of output files.')

args = parser.parse_args()


def compose(bucket_name, source_prefix, destination_prefix, max_size_in_bytes):
    print('Composing files in {} to {}'.format(f'gs://{bucket_name}{source_prefix}', f'gs://{bucket_name}{destination_prefix}'))
    storage_client = storage.Client()

    blobs = storage_client.list_blobs(bucket_name, prefix=source_prefix)

    current_batch_size = 0
    current_batch = []
    all_batches = []
    for blob in blobs:
        if (current_batch_size + blob.size) < max_size_in_bytes and len(current_batch) < GCS_MAX_FILES_FOR_COMBINE:
            current_batch.append(blob)
            current_batch_size += blob.size
        else:
            all_batches.append(current_batch)
            current_batch = [blob]
            current_batch_size = blob.size
    if current_batch:
        all_batches.append(current_batch)

    for index, batch in enumerate(all_batches):
        padded_index = str(index).zfill(12)
        bucket = storage_client.bucket(bucket_name)
        blob_name = destination_prefix + padded_index + '.gz'
        blob = bucket.blob(blob_name)

        print('Composing {} files to {}'.format(len(batch), blob_name))
        blob.compose(batch)


compose(args.bucket,
        source_prefix=args.input_folder,
        destination_prefix=args.output_folder,
        max_size_in_bytes=args.max_size_in_bytes)
