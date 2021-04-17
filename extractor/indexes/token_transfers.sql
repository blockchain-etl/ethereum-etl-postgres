alter table token_transfers add constraint token_transfers_pk primary key (transaction_hash, log_index);

create index token_transfers_block_timestamp_index on token_transfers (block_timestamp desc);

create index token_transfers_token_address_block_timestamp_index on token_transfers (token_address, block_timestamp desc);
create index token_transfers_from_address_block_timestamp_index on token_transfers (from_address, block_timestamp desc);
create index token_transfers_to_address_block_timestamp_index on token_transfers (to_address, block_timestamp desc);
