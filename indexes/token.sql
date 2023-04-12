alter table token add constraint token_pk primary key (address, block_number);

create index token_block_number_index on token (block_number desc);
