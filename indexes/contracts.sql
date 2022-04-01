alter table contracts add constraint contracts_pk primary key (address, block_number);

create index contracts_block_number_index on contracts (block_number desc);
create index contracts_is_erc20_index on contracts (is_erc20, block_number desc);
create index contracts_is_erc721_index on contracts (is_erc721, block_number desc);
