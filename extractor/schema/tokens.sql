create table tokens
(
    address varchar(42),
    name text,
    symbol text,
    decimals int(11),
    function_sighashes text[]
);