create table blocks
(
    timestamp timestamp,
    number bigint,
    hash varchar(66),
    parent_hash varchar(66),
    nonce varchar(42),
    sha3_uncles varchar(66),
    logs_bloom text,
    transactions_root varchar(66),
    state_root varchar(66),
    receipts_root varchar(66),
    miner varchar(42),
    difficulty numeric(38),
    total_difficulty numeric(38),
    size bigint,
    extra_data text,
    gas_limit bigint,
    gas_used bigint,
    transaction_count bigint
);