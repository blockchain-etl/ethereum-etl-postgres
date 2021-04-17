copy logs
from 's3://bsc-mainnet-data/logs/start_block=00000000/end_block=00009998/logs_00000000_00009998.csv'
iam_role 'arn:aws:iam::608514939847:role/redshift-mainnet'
delimiter ','
csv
IGNOREHEADER 1;
