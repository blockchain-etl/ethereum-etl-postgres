FROM ubuntu:16.04 as builder

# Prerequisites
RUN apt update
RUN apt install git make wget build-essential -y

RUN wget https://golang.org/dl/go1.16.3.linux-amd64.tar.gz
RUN tar -xvf go1.16.3.linux-amd64.tar.gz

RUN git clone https://github.com/binance-chain/bsc
WORKDIR bsc
RUN PATH=$PATH:/go/bin make geth

FROM debian:stretch-slim
WORKDIR /app
COPY --from=builder /bsc/build/bin/geth /usr/bin
COPY config.toml .
COPY genesis.json .
COPY run.sh .

# Let it run
CMD /app/run.sh
