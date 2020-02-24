alter table transactions add constraint transactions_pk primary key (hash);

create index idx_transactions_from_address_block_timestamp on transactions (last_name, first_name);