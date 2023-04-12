create table contract
(
    address varchar(42),
    bytecode text,
    function_sighashes text[],
    is_erc20 boolean,
    is_erc721 boolean,
    block_number bigint,
    block_hash varchar(66),
    block_timestamp timestamp
);
