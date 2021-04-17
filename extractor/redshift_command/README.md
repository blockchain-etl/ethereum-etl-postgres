## execute shchema / import
PGPASSWORD=pass psql -h localhost  -U awsuser -d mainnet -p 5439 -f example.sql -a

### check errros
check for errors: select * from STL_LOAD_ERRORS order by starttime desc;

### ssh tunel 
ssh -L 5439:redshift-demo.cvsy5ghzxvau.us-east-1.redshift.amazonaws.com:5439 -i ~/.ssh/engineering-barsum.pem ubuntu@107.21.27.87