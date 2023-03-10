# TODO: Update to work on other machines. Right now the path is to /Users/waylandhe which isn't ideal
psql $DATABASE_URL -c "\copy \"Contract\" (address,bytecode,function_sighashes,is_erc20,is_erc721,block_hash,block_number,block_timestamp) FROM '/Users/waylandhe/git/ethereum-etl-postgres/ethereum_data/flattened_contracts_fitered.csv' DELIMITER ',' CSV HEADER"
psql $DATABASE_URL -c "\copy \"Trace\" (transaction_hash,transaction_index,from_address,to_address,value,input,output,trace_type,call_type,reward_type,gas,gas_used,subtraces,trace_address,error,status,block_timestamp,block_number,block_hash,trace_id) FROM '/Users/waylandhe/git/ethereum-etl-postgres/ethereum_data/ethereum_traces_fitered.csv' DELIMITER ',' CSV HEADER"
psql $DATABASE_URL -c "\copy \"Block\" (timestamp,number,hash,parent_hash,nonce,sha3_uncles,logs_bloom,transactions_root,state_root,receipts_root,miner,difficulty,total_difficulty,size,extra_data,gas_limit,gas_used,transaction_count,base_fee_per_gas) FROM '/Users/waylandhe/git/ethereum-etl-postgres/ethereum_data/ethereum_blocks_fitered.csv' DELIMITER ',' CSV HEADER"
psql $DATABASE_URL -c "\copy \"Transaction\" (hash,nonce,transaction_index,from_address,to_address,value,gas,gas_price,input,receipt_cumulative_gas_used,receipt_gas_used,receipt_contract_address,receipt_root,receipt_status,block_timestamp,block_number,block_hash,max_fee_per_gas,max_priority_fee_per_gas,transaction_type,receipt_effective_gas_price) FROM '/Users/waylandhe/git/ethereum-etl-postgres/ethereum_data/ethereum_transactions_fitered.csv' DELIMITER ',' CSV HEADER"
