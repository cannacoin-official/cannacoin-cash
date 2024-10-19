# CannacoinCash

CannacoinCash is a decentralized cryptocurrency based on the Litecoin codebase. It aims to provide fast, secure, and low-cost payments by leveraging the power of blockchain technology. This project is a fork of Litecoin v0.21.3, with modifications to create a new, independent blockchain network.

## Table of Contents

- [Features](#features)
- [Modifications](#modifications)
- [Dependencies](#dependencies)
- [Building CannacoinCash](#building-cannacoincash)
- [Setting Up Configuration](#setting-up-configuration)
- [Generating a New Genesis Block](#generating-a-new-genesis-block)
- [Running CannacoinCash Daemon](#running-cannacoincash-daemon)
- [Mining CannacoinCash](#mining-cannacoincash)
- [License](#license)
- [Disclaimer](#disclaimer)

## Features

- **Fast Transactions**: Quick confirmation times for sending and receiving payments.
- **Decentralized Network**: Operates on a peer-to-peer network without central authority.
- **Modified Supply and Rewards**:
  - Total Supply: 21 million coins.
  - Block Reward: 100 coins per block.
  - Halving Interval: Every 210,000 blocks.
- **Scrypt Proof-of-Work Algorithm**: Uses Scrypt for mining, allowing for both CPU and GPU mining.

## Modifications

CannacoinCash introduces several changes to the original Litecoin codebase:

- **Renamed Coin**: All instances of "Litecoin" have been replaced with "CannacoinCash."
- **Network Ports**:
  - **P2P Port**: Changed from `9333` to `9388`.
  - **RPC Port**: Changed from `9332` to `9387`.
- **Network Magic Bytes**: Updated to create a separate network identity.
- **Consensus Parameters**:
  - **Subsidy Halving Interval**: Reduced from `840,000` to `210,000` blocks.
  - **Maximum Money Supply**: Reduced from `84,000,000` to `21,000,000` coins.
  - **Initial Block Reward**: Increased from `50` to `100` coins.
  - **Difficulty Adjustment**: Modified `powLimit`, `nPowTargetTimespan`, and `nPowTargetSpacing` for initial mining ease.
- **Genesis Block**: A new genesis block must be generated to start the CannacoinCash blockchain.

## Dependencies

Ensure your system has the following dependencies installed:

- Build Tools: `build-essential`, `libtool`, `autotools-dev`, `automake`, `pkg-config`, `bsdmainutils`, `curl`, `git`
- Libraries: `libssl-dev`, `libevent-dev`, `libboost-all-dev`, `libzmq3-dev`, `libprotobuf-dev`, `libqrencode-dev`, `libminiupnpc-dev`, `libdb-dev`, `libdb++-dev`
- Qt (Optional for GUI): `qtbase5-dev`, `qttools5-dev-tools`
- Protocol Buffers Compiler: `protobuf-compiler`

## Building CannacoinCash

Follow these steps to build CannacoinCash from source:

### 1. Update and Install Dependencies

```bash
sudo apt update
sudo apt install -y \
    build-essential libtool autotools-dev automake pkg-config bsdmainutils curl git \
    libssl-dev libevent-dev libboost-all-dev libzmq3-dev \
    libprotobuf-dev protobuf-compiler \
    libqrencode-dev libminiupnpc-dev \
    libdb-dev libdb++-dev \
    qtbase5-dev qttools5-dev-tools
```

### 2. Clone the Repository

```bash
cd ~
git clone https://github.com/litecoin-project/litecoin.git CannacoinCash
cd CannacoinCash
```

### 3. Modify the Codebase

#### Rename Instances of Litecoin

```bash
find . -type f \( -name "*.*" ! -name "*.png" ! -name "*.ico" ! -name "*.qrc" \) -exec sed -i 's/Litecoin/CannacoinCash/g' {} +
find . -type f \( -name "*.*" ! -name "*.png" ! -name "*.ico" ! -name "*.qrc" \) -exec sed -i 's/LITECOIN/CANNACOINCASH/g' {} +
find . -type f \( -name "*.*" ! -name "*.png" ! -name "*.ico" ! -name "*.qrc" \) -exec sed -i 's/litecoin/cannacoincash/g' {} +
```

#### Update Network Ports

```bash
find . -type f -exec sed -i 's/9333/9388/g' {} +  # P2P Port
find . -type f -exec sed -i 's/9332/9387/g' {} +  # RPC Port
```

#### Change Network Magic Bytes

In `src/chainparams.cpp`, modify the `pchMessageStart` array:

```bash
sed -i 's/pchMessageStart\[0\] = 0xfb;/pchMessageStart[0] = 0xca;/g' src/chainparams.cpp
sed -i 's/pchMessageStart\[1\] = 0xc0;/pchMessageStart[1] = 0xca;/g' src/chainparams.cpp
sed -i 's/pchMessageStart\[2\] = 0xb6;/pchMessageStart[2] = 0xca;/g' src/chainparams.cpp
sed -i 's/pchMessageStart\[3\] = 0xdb;/pchMessageStart[3] = 0xca;/g' src/chainparams.cpp
```

#### Update Consensus Parameters

- **Subsidy Halving Interval**:

  ```bash
  sed -i 's/consensus.nSubsidyHalvingInterval = 840000;/consensus.nSubsidyHalvingInterval = 210000;/g' src/chainparams.cpp
  ```

- **Maximum Money Supply**:

  ```bash
  sed -i 's/84000000/21000000/g' src/amount.h
  ```

- **Initial Mining Reward**:

  ```bash
  sed -i 's/50 \* COIN;/100 \* COIN;/g' src/validation.cpp
  ```

#### Adjust Difficulty Parameters

```bash
sed -i 's/consensus.powLimit = uint256S("00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");/consensus.powLimit = uint256S("00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");/g' src/chainparams.cpp
sed -i 's/consensus.nPowTargetTimespan = 3.5 \* 24 \* 60 \* 60;/consensus.nPowTargetTimespan = 24 * 60 * 60;/g' src/chainparams.cpp
sed -i 's/consensus.nPowTargetSpacing = 2.5 \* 60;/consensus.nPowTargetSpacing = 1 \* 60;/g' src/chainparams.cpp
```

#### Remove Checkpoints and DNS Seeds

```bash
# Remove existing checkpoints
sed -i '/checkpointData =/,+6d' src/chainparams.cpp

# Remove DNS seeds
sed -i '/vSeeds.emplace_back/d' src/chainparams.cpp
```

### 4. Build the Software

```bash
./autogen.sh
./configure --disable-tests --disable-bench
make -j$(nproc)
```

## Setting Up Configuration

Create the configuration directory and file:

```bash
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
```

**Note**: Replace `user` and `pass` with strong, unique credentials.

## Generating a New Genesis Block

Generating a new genesis block is a crucial step to start the CannacoinCash blockchain. This process requires manual intervention.

### Steps:

1. **Modify `chainparams.cpp`**:

   - Set `genesis.nTime` to the current Unix timestamp.
   - Set `genesis.nNonce` to `0` (will be updated during generation).
   - Adjust `genesis.nBits` for desired difficulty.
   - Optionally, set a unique `pszTimestamp`.

2. **Create a Genesis Block Generator Script**:

   - Write a script (e.g., in Python or C++) to calculate a valid genesis block hash.
   - Increment `nNonce` until the hash meets the difficulty target.

3. **Update Genesis Block Parameters**:

   - Replace `consensus.hashGenesisBlock` and `genesis.hashMerkleRoot` in `chainparams.cpp` with the new values.
   - Update `genesis.nNonce` and `genesis.nTime` accordingly.

4. **Rebuild the Software**:

   ```bash
   make clean
   ./autogen.sh
   ./configure --disable-tests --disable-bench
   make -j$(nproc)
   ```

5. **Verify Genesis Block**:

   - Start the daemon:

     ```bash
     src/cannacoincashd -daemon
     ```

   - Check the genesis block hash:

     ```bash
     src/cannacoincash-cli getblockhash 0
     ```

   - Ensure it matches `consensus.hashGenesisBlock`.

**Note**: Detailed instructions and scripts for generating a genesis block can be found in various online resources or cryptocurrency development guides.

## Running CannacoinCash Daemon

Start the CannacoinCash daemon:

```bash
src/cannacoincashd -daemon
```

Check the blockchain and network status:

```bash
src/cannacoincash-cli getblockchaininfo
src/cannacoincash-cli getnetworkinfo
```

## Mining CannacoinCash

Since internal mining commands are not available, use external mining software compatible with the Scrypt algorithm.

### Install CPU Miner (cpuminer)

```bash
sudo apt-get install -y git build-essential automake libcurl4-openssl-dev libjansson-dev
git clone https://github.com/pooler/cpuminer.git
cd cpuminer
./autogen.sh
./configure CFLAGS="-O3"
make
sudo make install
```

### Start Mining

```bash
minerd --url=http://127.0.0.1:9387 --user=user --pass=pass --threads=4
```

- Adjust `--threads` based on your CPU capabilities.
- Ensure `rpcuser` and `rpcpassword` match those in your `cannacoincash.conf`.

### Monitor Mining Progress

- **Mining Info**:

  ```bash
  src/cannacoincash-cli getmininginfo
  ```

- **Wallet Balance**:

  ```bash
  src/cannacoincash-cli getbalance
  ```

## License

CannacoinCash is released under the terms of the MIT license. See [COPYING](COPYING) for more information or see [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT).

## Disclaimer

- **Legal Considerations**: Ensure that creating and using CannacoinCash complies with all applicable laws and regulations in your jurisdiction.
- **Security**: Use strong credentials for your RPC user and password. Secure your wallet by encrypting it and keeping backups.
- **No Warranty**: This software is provided "as is" without warranty of any kind. Use at your own risk.

---

**Note**: This README reflects the current progress of the CannacoinCash project as of the latest updates. Further modifications and enhancements may be necessary for a fully functional and secure cryptocurrency network.
