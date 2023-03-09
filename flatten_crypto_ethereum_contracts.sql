select
    address,
    bytecode,
    -- convert bq array to array literal
    -- this allows us to export nested data to a csv and 
    -- import it to postgres as a text array
    concat('{', array_to_string(function_sighashes, ','), '}') as function_sighashes,
    is_erc20,
    is_erc721,
    block_hash,
    block_number,
    block_timestamp
from `bigquery-public-data.crypto_ethereum.contracts`
