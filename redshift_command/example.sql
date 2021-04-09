copy blocks
from 's3://bsc-mainnet-data/blocks/start_block=00000000/end_block=00009998/blocks_00000000_00009998.csv'
iam_role 'arn:aws:iam::608514939847:role/redshift-mainnet'
dateformat 'auto' delimiter ','
csv
IGNOREHEADER 1;
