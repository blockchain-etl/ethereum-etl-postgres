alter table log add constraint log_pk primary key (transaction_hash, log_index);

create index log_block_timestamp_index on log (block_timestamp desc);

create index log_address_block_timestamp_index on log (address, block_timestamp desc);
