alter table block add constraint block_pk primary key (hash);

create index block_timestamp_index on block (timestamp desc);

create unique index block_number_uindex on block (number desc);
