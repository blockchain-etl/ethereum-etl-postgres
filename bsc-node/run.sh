#!/usr/bin/env sh

geth --datadir /root/.ethereum init /app/genesis.json

geth --cache=4096 --rpc --rpcaddr 0.0.0.0 --rpcapi personal,admin,db,eth,net,web3,miner,shh,txpool,debug --ws --config /app/config.toml --datadir /app/data
