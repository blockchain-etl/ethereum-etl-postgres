alter table logs add constraint logs_pk primary key (transaction_hash, log_index);

create index logs_block_timestamp_index on logs (block_timestamp desc);

create index logs_address_block_timestamp_index on logs (address, block_timestamp desc);
