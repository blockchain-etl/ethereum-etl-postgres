alter table transactions add constraint transactions_pk primary key (hash);

create index transactions_block_timestamp_index on transactions (block_timestamp desc);

create index transactions_from_address_block_timestamp_index on transactions (from_address, block_timestamp desc);
create index transactions_to_address_block_timestamp_index on transactions (to_address, block_timestamp desc);
