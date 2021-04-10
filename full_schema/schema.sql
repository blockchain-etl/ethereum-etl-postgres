-- drop table blocks;

-- drop table contracts;

-- drop table logs;

-- drop table token_transfers;

drop table tokens;

drop table traces;

drop table transactions;

-- Done
-- create table blocks
-- (
--     number numeric,
--     hash varchar(66) not null,
--     parent_hash varchar(66),
--     nonce varchar(42),
--     sha3_uncles varchar(66),
--     logs_bloom varchar(5000),
--     transactions_root varchar(66),
--     state_root varchar(66),
--     receipts_root varchar(66),
--     miner varchar(42),
--     difficulty numeric(38),
--     total_difficulty numeric(38),
--     size bigint,
--     extra_data varchar(5000),
--     gas_limit bigint,
--     gas_used bigint,
--     timestamp numeric,
--     transaction_count bigint
-- )
-- sortkey("hash");

-- Done
-- create table contracts
-- (
--     address varchar(42),
--     bytecode varchar(max),
--     function_sighashes varchar(5000),
--     is_erc20 boolean,
--     is_erc721 boolean,
--     block_number numeric
-- );

-- create table logs
-- (
--     log_index bigint not null,
--     transaction_hash varchar(66) not null,
--     transaction_index bigint,
--     block_hash varchar(66),
--     block_number bigint,
--     address varchar(100),
--     data varchar(max),
--     topics varchar(2560)
-- )
-- sortkey(transaction_hash, log_index);

-- create table token_transfers
-- (
--     token_address varchar(42),
--     from_address varchar(42),
--     to_address varchar(42),
--     value numeric(38),
--     transaction_hash varchar(66) not null,
--     log_index bigint not null,
--     block_number bigint
-- )
-- sortkey(transaction_hash, log_index);

create table tokens
(
    address varchar(42),
    name text,
    symbol text,
    decimals numeric(11),
    function_sighashes text
);

create table traces
(
    transaction_hash varchar(66),
    transaction_index bigint,
    from_address varchar(42),
    to_address varchar(42),
    value numeric(38),
    input text,
    output text,
    trace_type varchar(16),
    call_type varchar(16),
    reward_type varchar(16),
    gas bigint,
    gas_used bigint,
    subtraces bigint,
    trace_address varchar(8192),
    error text,
    status int,
    block_timestamp numeric,
    block_number bigint,
    block_hash varchar(66),
    trace_id text not null
)
sortkey(trace_id);

create table transactions
(
    hash varchar(66) not null,
    nonce bigint,
    transaction_index bigint,
    from_address varchar(42),
    to_address varchar(42),
    value numeric(38),
    gas bigint,
    gas_price bigint,
    input text,
    receipt_cumulative_gas_used bigint,
    receipt_gas_used bigint,
    receipt_contract_address varchar(42),
    receipt_root varchar(66),
    receipt_status bigint,
    block_timestamp numeric,
    block_number bigint,
    block_hash varchar(66)
)
sortkey(hash);

-- TODO: Solve indexes and PK issues

-- alter table blocks add constraint blocks_pk primary key (hash);

-- alter table logs add constraint logs_pk primary key (transaction_hash, log_index);

-- alter table token_transfers add constraint token_transfers_pk primary key (transaction_hash, log_index);

alter table traces add constraint traces_pk primary key (trace_id);

alter table transactions add constraint transactions_pk primary key (hash);