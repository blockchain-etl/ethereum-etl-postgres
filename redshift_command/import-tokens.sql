copy tokens
from 's3://bsc-mainnet-data/tokens/start_block=00149985/end_block=00159983/tokens_00149985_00159983.csv'
iam_role 'arn:aws:iam::608514939847:role/redshift-mainnet'
delimiter ','
csv
IGNOREHEADER 1;
