alter table contract add constraint contract_pk primary key (address, block_number);

create index contract_block_number_index on contract (block_number desc);
create index contract_is_erc20_index on contract (is_erc20, block_number desc);
create index contract_is_erc721_index on contract (is_erc721, block_number desc);
