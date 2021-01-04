create table token_transfer_amendments
(
    token_address varchar(42),
    from_address varchar(42),
    to_address varchar(42),
    value numeric(78),
    transaction_hash varchar(66),
    log_index bigint,
    block_timestamp timestamp,
    block_number bigint,
    block_hash varchar(66),
    is_applied boolean DEFAULT false
);