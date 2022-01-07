create table tokens
(
    address varchar(42),
    name text,
    symbol text,
    decimals int(11),
    function_sighashes text[],
    total_supply numeric(78),
    block_number bigint
);
