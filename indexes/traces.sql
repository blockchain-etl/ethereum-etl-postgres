-- TODO: add trace_id to traces table to be used a primary key

create index traces_block_timestamp_index on traces (block_timestamp desc);

create index traces_from_address_block_timestamp_index on traces (from_address, block_timestamp desc);
create index traces_to_address_block_timestamp_index on traces (to_address, block_timestamp desc);