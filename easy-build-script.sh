#!/bin/bash

# CannacoinCash Build Script

# Exit immediately if a command exits with a non-zero status
set -e

# Update and install dependencies
sudo apt update
sudo apt install -y \
    build-essential libtool autotools-dev automake pkg-config bsdmainutils curl git \
    libssl-dev libevent-dev libboost-all-dev libzmq3-dev \
    libprotobuf-dev protobuf-compiler \
    libqrencode-dev libminiupnpc-dev \
    libdb-dev libdb++-dev \
    qtbase5-dev qttools5-dev-tools \
    libgmp-dev libjansson-dev

# Clone the Litecoin repository and rename it
cd ~
git clone https://github.com/litecoin-project/litecoin.git CannacoinCash
cd CannacoinCash

# Replace all instances of Litecoin with CannacoinCash
find . -type f \( -name "*.*" ! -name "*.png" ! -name "*.ico" ! -name "*.qrc" \) -exec sed -i 's/Litecoin/CannacoinCash/g' {} +
find . -type f \( -name "*.*" ! -name "*.png" ! -name "*.ico" ! -name "*.qrc" \) -exec sed -i 's/LITECOIN/CANNACOINCASH/g' {} +
find . -type f \( -name "*.*" ! -name "*.png" ! -name "*.ico" ! -name "*.qrc" \) -exec sed -i 's/litecoin/cannacoincash/g' {} +

# Change default network ports
find . -type f -exec sed -i 's/9333/9388/g' {} +  # New P2P Port
find . -type f -exec sed -i 's/9332/9387/g' {} +  # New RPC Port

# Change network magic bytes in chainparams.cpp
sed -i 's/pchMessageStart\[0\] = 0xfb;/pchMessageStart[0] = 0xca;/g' src/chainparams.cpp
sed -i 's/pchMessageStart\[1\] = 0xc0;/pchMessageStart[1] = 0xca;/g' src/chainparams.cpp
sed -i 's/pchMessageStart\[2\] = 0xb6;/pchMessageStart[2] = 0xca;/g' src/chainparams.cpp
sed -i 's/pchMessageStart\[3\] = 0xdb;/pchMessageStart[3] = 0xca;/g' src/chainparams.cpp

# Change the subsidy halving interval to 210,000 blocks
sed -i 's/consensus.nSubsidyHalvingInterval = 840000;/consensus.nSubsidyHalvingInterval = 210000;/g' src/chainparams.cpp

# Change the maximum money supply to 21 million coins
sed -i 's/84000000/21000000/g' src/amount.h

# Change the initial mining reward to 100 coins
sed -i 's/50 \* COIN;/100 \* COIN;/g' src/validation.cpp

# Adjust difficulty parameters for easier initial mining
sed -i 's/consensus.powLimit = uint256S("00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");/consensus.powLimit = uint256S("00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");/g' src/chainparams.cpp
sed -i 's/consensus.nPowTargetTimespan = 3.5 \* 24 \* 60 \* 60;/consensus.nPowTargetTimespan = 1 \* 60 \* 60;/g' src/chainparams.cpp  # Adjust as needed
sed -i 's/consensus.nPowTargetSpacing = 2.5 \* 60;/consensus.nPowTargetSpacing = 1 \* 60;/g' src/chainparams.cpp  # Adjust as needed

# Remove existing checkpoints and DNS seeds
sed -i '/checkpointData =/,+6d' src/chainparams.cpp
sed -i '/vSeeds.emplace_back/d' src/chainparams.cpp

# Create configuration directory and file
mkdir -p ~/.cannacoincash
cat >~/.cannacoincash/cannacoincash.conf <<EOL
rpcuser=user
rpcpassword=pass
rpcallowip=127.0.0.1
rpcport=9387
port=9388
listen=1
server=1
daemon=1
txindex=1
EOL

# Build the CannacoinCash software
./autogen.sh
./configure --disable-tests --disable-bench
make -j$(nproc)

# Prompt user to generate new genesis block
echo "=================================================================="
echo "Genesis Block Generation Required"
echo "=================================================================="
echo "A new genesis block needs to be generated to start the CannacoinCash blockchain."
echo "Please follow these steps:"
echo "1. Modify 'src/chainparams.cpp' to set 'genesis.nTime' to the current Unix timestamp."
echo "2. Set 'genesis.nNonce' to 0."
echo "3. Use a genesis block generator script to find a valid genesis hash."
echo "4. Update 'consensus.hashGenesisBlock' and 'genesis.hashMerkleRoot' in 'chainparams.cpp' with the new values."
echo "5. Rebuild the software with 'make clean' and 'make -j\$(nproc)'."
echo "6. Start the CannacoinCash daemon with './src/cannacoincashd -daemon'."
echo "=================================================================="

# Completion message
echo "CannacoinCash codebase has been prepared."
echo "Please generate a new genesis block as per the instructions above."
