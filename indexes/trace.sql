alter table trace add constraint trace_pk primary key (trace_id);

create index trace_block_timestamp_index on trace (block_timestamp desc);

create index trace_from_address_block_timestamp_index on trace (from_address, block_timestamp desc);
create index trace_to_address_block_timestamp_index on trace (to_address, block_timestamp desc);