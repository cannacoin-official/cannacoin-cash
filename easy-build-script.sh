#!/bin/bash

# Update and install dependencies
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils curl git

# Install Boost libraries
sudo apt install -y libboost-all-dev

# Install other necessary libraries
sudo apt install -y libevent-dev libminiupnpc-dev libzmq3-dev

# Remove any existing Berkeley DB packages (optional)
sudo apt remove -y libdb-dev libdb++-dev

# Install Berkeley DB 4.8
cd ~
# Download Berkeley DB 4.8 source code
wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz

# Extract the archive
tar -xzvf db-4.8.30.NC.tar.gz

# Build and install Berkeley DB 4.8
cd db-4.8.30.NC/build_unix/
# Configure the build with the appropriate prefix and options
../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/usr/local/BerkeleyDB.4.8
# Compile and install
make
sudo make install

# Set the Berkeley DB 4.8 environment variables
export BDB_PREFIX='/usr/local/BerkeleyDB.4.8'

# Clone the Litecoin repository and rename it
cd ~
git clone https://github.com/litecoin-project/litecoin.git CannacoinCash
cd CannacoinCash

# Replace all instances of Litecoin with CannacoinCash
find . -type f -exec sed -i 's/Litecoin/CannacoinCash/g' {} +
find . -type f -exec sed -i 's/LITECOIN/CANNACOINCASH/g' {} +
find . -type f -exec sed -i 's/litecoin/cannacoincash/g' {} +

# Change default network ports
find . -type f -exec sed -i 's/9333/9388/g' {} +  # New P2P Port
find . -type f -exec sed -i 's/9332/9387/g' {} +  # New RPC Port

# Change network magic bytes
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

# Create configuration directory and file
mkdir -p ~/.cannacoincash
echo "rpcuser=user" > ~/.cannacoincash/cannacoincash.conf
echo "rpcpassword=pass" >> ~/.cannacoincash/cannacoincash.conf
echo "rpcallowip=127.0.0.1" >> ~/.cannacoincash/cannacoincash.conf
echo "rpcport=9387" >> ~/.cannacoincash/cannacoincash.conf
echo "server=1" >> ~/.cannacoincash/cannacoincash.conf
echo "daemon=1" >> ~/.cannacoincash/cannacoincash.conf

# Build CannacoinCash with Berkeley DB 4.8
./autogen.sh
./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" \
    --with-incompatible-bdb \
    --disable-shared \
    --enable-cxx \
    --disable-tests \
    --disable-bench

make

# Start the CannacoinCash daemon
src/cannacoincashd -daemon

# Completion message
echo "CannacoinCash successfully built and the daemon is now running."
