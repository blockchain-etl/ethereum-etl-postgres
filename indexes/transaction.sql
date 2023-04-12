alter table transaction add constraint transaction_pk primary key (hash);

create index transaction_block_timestamp_index on transaction (block_timestamp desc);

create index transaction_from_address_block_timestamp_index on transaction (from_address, block_timestamp desc);
create index transaction_to_address_block_timestamp_index on transaction (to_address, block_timestamp desc);
