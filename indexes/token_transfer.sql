alter table token_transfer add constraint token_transfer_pk primary key (transaction_hash, log_index);

create index token_transfer_block_timestamp_index on token_transfer (block_timestamp desc);

create index token_transfer_token_address_block_timestamp_index on token_transfer (token_address, block_timestamp desc);
create index token_transfer_from_address_block_timestamp_index on token_transfer (from_address, block_timestamp desc);
create index token_transfer_to_address_block_timestamp_index on token_transfer (to_address, block_timestamp desc);
