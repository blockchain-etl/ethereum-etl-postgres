alter table traces add constraint traces_pk primary key (trace_id);

create index traces_block_timestamp_index on traces (block_timestamp desc);

create index traces_from_address_block_timestamp_index on traces (from_address, block_timestamp desc);
create index traces_to_address_block_timestamp_index on traces (to_address, block_timestamp desc);