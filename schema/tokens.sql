create table tokens
(
    address varchar(42),
    name text,
    symbol text,
    decimals int,
    total_supply numeric(78),
    block_number bigint,
    block_hash varchar(66),
    block_timestamp timestamp,
    function_sighashes text[]
);
