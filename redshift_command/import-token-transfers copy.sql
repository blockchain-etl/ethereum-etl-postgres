copy token_transfers
from 's3://bsc-mainnet-data/token_transfers/start_block=00139986/end_block=00149984/token_transfers_00139986_00149984.csv'
iam_role 'arn:aws:iam::608514939847:role/redshift-mainnet'
delimiter ','
csv
IGNOREHEADER 1;
