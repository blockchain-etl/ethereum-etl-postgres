alter table blocks add constraint blocks_pk primary key (hash);

create index blocks_timestamp_index on blocks (timestamp desc);

create unique index blocks_number_uindex on blocks (number desc);
