create table log
(
    log_index bigint,
    transaction_hash varchar(66),
    transaction_index bigint,
    address varchar(42),
    data text,
    topic0 varchar(66),
    topic1 varchar(66),
    topic2 varchar(66),
    topic3 varchar(66),
    block_timestamp timestamp,
    block_number bigint,
    block_hash varchar(66)
);