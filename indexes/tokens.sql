alter table tokens add constraint tokens_pk primary key (address, block_number);

create index tokens_block_number_index on tokens (block_number desc);
