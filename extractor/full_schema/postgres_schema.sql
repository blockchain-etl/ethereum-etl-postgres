drop table blocks;

drop table contracts;

drop table logs;

drop table token_transfers;

drop table tokens;

drop table traces;

drop table transactions;

drop table receipts;

-- number,hash,parent_hash,nonce,sha3_uncles,logs_bloom,transactions_root,state_root,receipts_root,miner,difficulty,total_difficulty,size,extra_data,gas_limit,gas_used,timestamp,transaction_count
-- \copy blocks FROM 'blocks.csv' DELIMITER ',' CSV HEADER
create table blocks
(
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
    timestamp numeric, -- timestamp type not working changed to numeric
    transaction_count bigint
);

-- address,bytecode,function_sighashes,is_erc20,is_erc721,block_number
-- \copy contracts FROM 'contracts.csv' DELIMITER ',' CSV HEADER
create table contracts
(
    address varchar(42),
    bytecode text,
    function_sighashes text, -- we need to change how we generate this "value1,value,value3" to "{{value1,value2,value3}}" on the meanwhile I changed from text[] to text
    is_erc20 boolean, -- added
    is_erc721 boolean, -- added
    block_number bigint -- added
);

-- log_index,transaction_hash,transaction_index,block_hash,block_number,address,data,topics
-- \copy logs FROM 'logs.csv' DELIMITER ',' CSV HEADER
create table logs
(
    log_index bigint,
    transaction_hash varchar(66),
    transaction_index bigint,
    block_hash varchar(66),
    block_number bigint,
    address varchar(42), -- from 42 to 100
    data text,
    topics text -- added column, also we need to transform data to array, I changed from text[] to text (missing in original schema) we need to change how we generate this "value1,value,value3" to "{{value1,value2,value3}}"
    -- topic0 varchar(66), -- removed (not present on CSVs)
    -- topic1 varchar(66), -- removed (not present on CSVs)
    -- topic2 varchar(66), -- removed (not present on CSVs)
    -- topic3 varchar(66), -- removed (not present on CSVs)
    -- block_timestamp timestamp, -- removed (not present on CSVs)
);

-- token_address,from_address,to_address,value,transaction_hash,log_index,block_number
-- \copy token_transfers FROM 'token_transfers.csv' DELIMITER ',' CSV HEADER
create table token_transfers
(
    token_address varchar(42),
    from_address varchar(42),
    to_address varchar(42),
    value numeric(78),
    transaction_hash varchar(66),
    log_index bigint,
    -- block_timestamp -- removed (not present on CSVs)
    block_number bigint
    -- block_hash varchar(66) -- removed (not present on CSVs)
);

-- address,symbol,name,decimals,total_supply,block_number
-- \copy tokens FROM 'tokens.csv' DELIMITER ',' CSV HEADER
create table tokens
(
    address varchar(42),
    symbol text,
    name text,
    decimals integer, -- from int(11) not compatible with postgresql to integer
    total_supply text, -- added, but seems to be optional https://ethereum-etl.readthedocs.io/en/latest/limitations/
    block_number bigint -- added
    -- function_sighashes text[] -- removed (not present on CSVs)
);

-- Not present
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

-- hash,nonce,block_hash,block_number,transaction_index,from_address,to_address,value,gas,gas_price,input,block_timestamp
-- \copy transactions FROM 'transactions.csv' DELIMITER ',' CSV HEADER
create table transactions
(
    hash varchar(66),
    nonce bigint,
    block_hash varchar(66),
    block_number bigint,
    transaction_index bigint,
    from_address varchar(42),
    to_address varchar(42),
    value numeric(38),
    gas bigint,
    gas_price bigint,
    input text,
    -- receipt_cumulative_gas_used bigint, -- removed (not present on CSVs)
    -- receipt_gas_used bigint, -- removed (not present on CSVs)
    -- receipt_contract_address varchar(42), -- removed (not present on CSVs)
    -- receipt_root varchar(66), -- removed (not present on CSVs)
    -- receipt_status bigint, -- removed (not present on CSVs)
    block_timestamp numeric -- timestamp type not working changed to numeric
);


-- transaction_hash,transaction_index,block_hash,block_number,cumulative_gas_used,gas_used,contract_address,root,status
-- \copy receipts FROM 'receipts.csv' DELIMITER ',' CSV HEADER
create table receipts
(
    transaction_hash varchar(66),
    transaction_index bigint,
    block_hash varchar(66),
    block_number bigint,
    cumulative_gas_used bigint,
    gas_used bigint,
    contract_address varchar(42),
    root varchar(66),
    status bigint
);

alter table blocks add constraint blocks_pk primary key (hash);

create index blocks_timestamp_index on blocks (timestamp desc);

create unique index blocks_number_uindex on blocks (number desc);

alter table logs add constraint logs_pk primary key (transaction_hash, log_index); 

-- create index logs_block_timestamp_index on logs (block_timestamp desc); -- removed (not present on CSVs) -- removed (not present on CSVs)

-- create index logs_address_block_timestamp_index on logs (address, block_timestamp desc); -- removed (not present on CSVs)

alter table token_transfers add constraint token_transfers_pk primary key (transaction_hash, log_index);

-- create index token_transfers_block_timestamp_index on token_transfers (block_timestamp desc); -- removed (not present on CSVs)

create index token_transfers_token_address_block_timestamp_index on token_transfers (token_address desc); -- modified because block_timestamp (not present on CSVs)
create index token_transfers_from_address_block_timestamp_index on token_transfers (from_address desc); -- modified because block_timestamp (not present on CSVs)
create index token_transfers_to_address_block_timestamp_index on token_transfers (to_address desc); -- modified because block_timestamp (not present on CSVs)

alter table traces add constraint traces_pk primary key (trace_id);

create index traces_block_timestamp_index on traces (block_timestamp desc);

create index traces_from_address_block_timestamp_index on traces (from_address, block_timestamp desc);
create index traces_to_address_block_timestamp_index on traces (to_address, block_timestamp desc);

alter table transactions add constraint transactions_pk primary key (hash);

create index transactions_block_timestamp_index on transactions (block_timestamp desc);

create index transactions_from_address_block_timestamp_index on transactions (from_address, block_timestamp desc);
create index transactions_to_address_block_timestamp_index on transactions (to_address, block_timestamp desc);
