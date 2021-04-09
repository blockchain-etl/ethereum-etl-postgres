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

create table contracts
(
    address varchar(42),
    bytecode text,
    function_sighashes text[]
);

create table logs
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

create table token_transfers
(
    token_address varchar(42),
    from_address varchar(42),
    to_address varchar(42),
    value numeric(78),
    transaction_hash varchar(66),
    log_index bigint,
    block_timestamp timestamp,
    block_number bigint,
    block_hash varchar(66)
);

create table tokens
(
    address varchar(42),
    name text,
    symbol text,
    decimals int(11),
    function_sighashes text[]
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
    block_timestamp timestamp,
    block_number bigint,
    block_hash varchar(66),
    trace_id text
);

create table transactions
(
    hash varchar(66),
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
    block_timestamp timestamp,
    block_number bigint,
    block_hash varchar(66)
);

alter table blocks add constraint blocks_pk primary key (hash);

create index blocks_timestamp_index on blocks (timestamp desc);

create unique index blocks_number_uindex on blocks (number desc);

alter table logs add constraint logs_pk primary key (transaction_hash, log_index);

create index logs_block_timestamp_index on logs (block_timestamp desc);

create index logs_address_block_timestamp_index on logs (address, block_timestamp desc);

alter table token_transfers add constraint token_transfers_pk primary key (transaction_hash, log_index);

create index token_transfers_block_timestamp_index on token_transfers (block_timestamp desc);

create index token_transfers_token_address_block_timestamp_index on token_transfers (token_address, block_timestamp desc);
create index token_transfers_from_address_block_timestamp_index on token_transfers (from_address, block_timestamp desc);
create index token_transfers_to_address_block_timestamp_index on token_transfers (to_address, block_timestamp desc);

alter table traces add constraint traces_pk primary key (trace_id);

create index traces_block_timestamp_index on traces (block_timestamp desc);

create index traces_from_address_block_timestamp_index on traces (from_address, block_timestamp desc);
create index traces_to_address_block_timestamp_index on traces (to_address, block_timestamp desc);

alter table transactions add constraint transactions_pk primary key (hash);

create index transactions_block_timestamp_index on transactions (block_timestamp desc);

create index transactions_from_address_block_timestamp_index on transactions (from_address, block_timestamp desc);
create index transactions_to_address_block_timestamp_index on transactions (to_address, block_timestamp desc);