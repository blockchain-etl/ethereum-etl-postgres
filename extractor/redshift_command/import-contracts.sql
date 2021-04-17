copy contracts
from 's3://bsc-mainnet-data/contracts/start_block=00049995/end_block=00059993/contracts_00049995_00059993.csv'
iam_role 'arn:aws:iam::608514939847:role/redshift-mainnet'
delimiter ','
csv
IGNOREHEADER 1;
