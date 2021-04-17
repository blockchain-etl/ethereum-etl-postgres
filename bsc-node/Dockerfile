FROM ubuntu:16.04

# Prerequisites
RUN apt update
RUN apt install git make wget build-essential -y

WORKDIR /app
RUN wget https://github.com/binance-chain/bsc/releases/download/v1.0.7/geth_linux
RUN mv /app/geth_linux /usr/bin/geth
RUN chmod +x /usr/bin/geth

COPY config.toml .
COPY genesis.json .
COPY run.sh .

# Let it run
CMD /app/run.sh
