#!/bin/bash

sudo apt update
sudo apt install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils git
sudo apt install -y libboost-all-dev
sudo apt install -y libdb-dev libdb++-dev
sudo apt install -y qtbase5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
sudo apt install -y libqrencode-dev
sudo apt install -y libminiupnpc-dev

cd ~
git clone https://github.com/litecoin-project/litecoin.git CannacoinCash
cd CannacoinCash

find . -type f -exec sed -i 's/Litecoin/CannacoinCash/g' {} +
find . -type f -exec sed -i 's/LITECOIN/CANNACOINCASH/g' {} +
find . -type f -exec sed -i 's/litecoin/cannacoincash/g' {} +

find . -type f -exec sed -i 's/9333/9388/g' {} +  # New P2P Port
find . -type f -exec sed -i 's/9332/9387/g' {} +  # New RPC Port

# Change magic bytes
sed -i 's/0xdbb6c0fb/0xcacacaca/g' src/chainparams.cpp
sed -i 's/0xfbc0b6db/0xcacacacb/g' src/chainparams.cpp
sed -i 's/0xd9b4bef9/0xcacacacc/g' src/chainparams.cpp
sed -i 's/0xdab5bffa/0xcacacacd/g' src/chainparams.cpp

# Change the subsidy halving interval to 210,000 blocks
sed -i 's/consensus.nSubsidyHalvingInterval = 840000;/consensus.nSubsidyHalvingInterval = 210000;/g' src/chainparams.cpp
sed -i 's/static const int nSubsidyHalvingInterval = 840000;/static const int nSubsidyHalvingInterval = 210000;/g' src/consensus/consensus.h

# Change the maximum money supply to 21 million coins
sed -i 's/static const CAmount MAX_MONEY = 84000000 \* COIN;/static const CAmount MAX_MONEY = 21000000 \* COIN;/g' src/amount.h

# Change the initial mining reward to 100 coins
sed -i 's/CAmount nSubsidy = 50 \* COIN;/CAmount nSubsidy = 100 \* COIN;/g' src/validation.cpp

mkdir ~/.cannacoincash
echo "rpcuser=user" > ~/.cannacoincash/cannacoincash.conf
echo "rpcpassword=pass" >> ~/.cannacoincash/cannacoincash.conf
echo "server=1" >> ~/.cannacoincash/cannacoincash.conf

# Build the CannacoinCash software
./autogen.sh
./configure
make

# Start the CannacoinCash daemon
src/cannacoincashd -daemon

# Completion message
echo "CannacoinCash successfully built and the daemon is now running."
