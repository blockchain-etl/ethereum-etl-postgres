select
    log_index,
    transaction_hash,
    transaction_index,
    address,
    data,
    topics[SAFE_OFFSET(0)] AS topic0,
    topics[SAFE_OFFSET(1)] AS topic1,
    topics[SAFE_OFFSET(2)] AS topic2,
    topics[SAFE_OFFSET(3)] AS topic3,
    block_timestamp,
    block_number,
    block_hash
from `bigquery-public-data.crypto_ethereum.logs`