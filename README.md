# cannacoin-cash

CannacoinCash is a cryptocurrency forked from Litecoin. This guide provides step-by-step instructions to create, build, and start mining CannacoinCash.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installation and Setup](#installation-and-setup)
  - [1. Update and Install Dependencies](#1-update-and-install-dependencies)
  - [2. Clone the Litecoin Repository](#2-clone-the-litecoin-repository)
  - [3. Rename Litecoin to CannacoinCash](#3-rename-litecoin-to-cannacoincash)
  - [4. Change Default Network Ports](#4-change-default-network-ports)
  - [5. Change Network Magic Bytes](#5-change-network-magic-bytes)
  - [6. Modify Max Supply and Mining Reward](#6-modify-max-supply-and-mining-reward)
  - [7. Create Configuration Directory and File](#7-create-configuration-directory-and-file)
- [Compiling CannacoinCash](#compiling-cannacoincash)
- [Starting the CannacoinCash Daemon](#starting-the-cannacoincash-daemon)
- [Mining CannacoinCash](#mining-cannacoincash)
  - [Option A: Using the Built-in Miner (CPU Mining)](#option-a-using-the-built-in-miner-cpu-mining)
  - [Option B: Using cpuminer](#option-b-using-cpuminer)
  - [Option C: Using sgminer (GPU Mining)](#option-c-using-sgminer-gpu-mining)
- [Adjusting Network Parameters (Optional)](#adjusting-network-parameters-optional)
- [Generating a New Genesis Block (If Necessary)](#generating-a-new-genesis-block-if-necessary)
- [Connecting Additional Nodes](#connecting-additional-nodes)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Conclusion](#conclusion)
- [License](#license)

---

## Introduction

CannacoinCash is a new cryptocurrency created by forking the Litecoin codebase. This guide walks you through the process of setting up CannacoinCash on your Ubuntu system, compiling the source code, configuring the node, and starting to mine CannacoinCash.

## Prerequisites

- An Ubuntu system (18.04 or later recommended)
- Basic knowledge of command-line operations
- Sufficient system resources for compiling and mining (CPU/GPU power, RAM)

## Installation and Setup

### 1. Update and Install Dependencies

Open a terminal and run the following commands to update your system and install the necessary dependencies:

```bash
sudo apt update
sudo apt install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils git
sudo apt install -y libboost-all-dev
sudo apt install -y libdb-dev libdb++-dev
sudo apt install -y qtbase5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
sudo apt install -y libqrencode-dev
sudo apt install -y libminiupnpc-dev
```

### 2. Clone the Litecoin Repository

Clone the Litecoin repository from GitHub and rename it to `CannacoinCash`:

```bash
cd ~
git clone https://github.com/litecoin-project/litecoin.git CannacoinCash
cd CannacoinCash
```

### 3. Rename Litecoin to CannacoinCash

Replace all instances of "Litecoin" with "CannacoinCash" throughout the codebase:

```bash
find . -type f -exec sed -i 's/Litecoin/CannacoinCash/g' {} +
find . -type f -exec sed -i 's/LITECOIN/CANNACOINCASH/g' {} +
find . -type f -exec sed -i 's/litecoin/cannacoincash/g' {} +
```

### 4. Change Default Network Ports

Modify the default P2P and RPC ports to prevent conflicts with Litecoin:

```bash
find . -type f -exec sed -i 's/9333/9388/g' {} +  # New P2P Port
find . -type f -exec sed -i 's/9332/9387/g' {} +  # New RPC Port
```

### 5. Change Network Magic Bytes

Update the network magic bytes to establish a distinct network:

```bash
sed -i 's/0xdbb6c0fb/0xcacacaca/g' src/chainparams.cpp
sed -i 's/0xfbc0b6db/0xcacacacb/g' src/chainparams.cpp
sed -i 's/0xd9b4bef9/0xcacacacc/g' src/chainparams.cpp
sed -i 's/0xdab5bffa/0xcacacacd/g' src/chainparams.cpp
```

### 6. Modify Max Supply and Mining Reward

#### Change the Subsidy Halving Interval

Modify the subsidy halving interval to change how often the mining reward halves.

Update `src/chainparams.cpp`:

```bash
sed -i 's/consensus.nSubsidyHalvingInterval = 840000;/consensus.nSubsidyHalvingInterval = 210000;/g' src/chainparams.cpp
```

Update `src/consensus/consensus.h`:

```bash
sed -i 's/static const int nSubsidyHalvingInterval = 840000;/static const int nSubsidyHalvingInterval = 210000;/g' src/consensus/consensus.h
```

#### Change the Maximum Money Supply

Modify `src/amount.h` to set the maximum number of coins:

```bash
sed -i 's/static const CAmount MAX_MONEY = 84000000 \* COIN;/static const CAmount MAX_MONEY = 21000000 \* COIN;/g' src/amount.h
```

#### Change the Initial Mining Reward

Update the initial mining reward in `src/validation.cpp`:

```bash
sed -i 's/CAmount nSubsidy = 50 \* COIN;/CAmount nSubsidy = 100 \* COIN;/g' src/validation.cpp
```

**Note:** If the original value is different (e.g., `25 * COIN`), adjust the `sed` command accordingly.

### 7. Create Configuration Directory and File

Set up the configuration for the CannacoinCash daemon:

```bash
mkdir ~/.cannacoincash
nano ~/.cannacoincash/cannacoincash.conf
```

Add the following lines to `cannacoincash.conf`:

```
rpcuser=user
rpcpassword=pass
rpcallowip=127.0.0.1
rpcport=9387
server=1
daemon=1
```

**Note:** Replace `user` and `pass` with secure credentials.

## Compiling CannacoinCash

Compile the CannacoinCash software from the modified source code:

```bash
./autogen.sh
./configure
make
```

- **`./autogen.sh`**: Prepares the build system.
- **`./configure`**: Configures the build options.
- **`make`**: Compiles the software.

## Starting the CannacoinCash Daemon

Start the CannacoinCash daemon in the background:

```bash
src/cannacoincashd -daemon
```

Check if the daemon is running:

```bash
src/cannacoincash-cli getblockchaininfo
```

You should see blockchain information confirming that the daemon is operational.

## Mining CannacoinCash

You can begin mining CannacoinCash using one of the following methods:

### Option A: Using the Built-in Miner (CPU Mining)

**Note:** The built-in miner may be disabled. If so, proceed to Option B.

Start mining:

```bash
src/cannacoincash-cli generate <number_of_blocks>
```

- Replace `<number_of_blocks>` with the number of blocks you want to mine.

Check mining progress:

```bash
src/cannacoincash-cli getmininginfo
```

### Option B: Using cpuminer

#### Install cpuminer

```bash
sudo apt-get install -y git build-essential automake libcurl4-openssl-dev
git clone https://github.com/pooler/cpuminer.git
cd cpuminer
./autogen.sh
CFLAGS="-O3" ./configure
make
sudo make install
```

#### Start Mining with cpuminer

```bash
minerd --url=http://localhost:9387 --user=user --pass=pass --threads=4
```

- Ensure `rpcuser` and `rpcpassword` match those in `cannacoincash.conf`.
- Adjust `--threads` according to your CPU cores.

### Option C: Using sgminer (GPU Mining)

#### Install sgminer (For AMD GPUs)

```bash
sudo apt-get install -y git build-essential autoconf libtool libcurl4-openssl-dev libncurses5-dev pkg-config
git clone https://github.com/sgminer-dev/sgminer.git
cd sgminer
./autogen.sh
./configure --enable-scrypt
make
sudo make install
```

#### Start Mining with sgminer

```bash
sgminer -k scrypt -o http://localhost:9387 -u user -p pass
```

- Replace `user` and `pass` with your RPC credentials.

**For NVIDIA GPUs**, consider using `ccminer`.

## Adjusting Network Parameters (Optional)

You may need to adjust network parameters to make mining feasible.

Modify `src/chainparams.cpp`:

```bash
nano src/chainparams.cpp
```

Adjust parameters such as:

- `consensus.powLimit`
- `consensus.nPowTargetTimespan`
- `consensus.nPowTargetSpacing`

Recompile the daemon after making changes:

```bash
make clean
./autogen.sh
./configure
make
```

## Generating a New Genesis Block (If Necessary)

If your node fails to start due to genesis block issues, generate a new one.

### Steps to Generate a New Genesis Block

1. **Modify `chainparams.cpp`:**

   - Set `genesis.nTime` and `genesis.nNonce` to new values.
   - Adjust `genesis.nBits` for desired difficulty.

2. **Generate Genesis Block:**

   - Use a Genesis Block Generator script or write a simple program.
   - Calculate `hashGenesisBlock` and `genesisMerkleRoot`.

3. **Update Genesis Parameters:**

   - Replace existing parameters in `chainparams.cpp` with new values.

4. **Recompile the Daemon:**

   ```bash
   make clean
   ./autogen.sh
   ./configure
   make
   ```

5. **Start the Daemon:**

   ```bash
   src/cannacoincashd -daemon
   ```

## Connecting Additional Nodes

To create a robust network, run multiple nodes.

- Set up additional nodes on other machines.
- Use the `addnode` parameter in `cannacoincash.conf`:

  ```
  addnode=your.main.node.ip
  ```

- Restart the daemon:

  ```bash
  src/cannacoincash-cli stop
  src/cannacoincashd -daemon
  ```

## Security Considerations

- **Secure RPC Credentials:**

  - Use strong, unique `rpcuser` and `rpcpassword`.

- **Firewall Settings:**

  - Configure firewall to allow only necessary connections.
  - Close unnecessary ports.

- **Regular Backups:**

  - Backup `wallet.dat` regularly.
  - Store backups securely.

## Troubleshooting

- **Daemon Fails to Start:**

  - Check `~/.cannacoincash/debug.log` for errors.
  - Ensure all dependencies are installed.

- **Mining Software Can't Connect:**

  - Verify the daemon is running on port `9387`.
  - Ensure `rpcallowip` in `cannacoincash.conf` allows connections.

- **Low Hash Rate:**

  - Optimize mining software settings.
  - Update hardware drivers.

## Conclusion

By following this guide, you've successfully forked Litecoin to create CannacoinCash, compiled the software, configured your node, and started mining. Remember to maintain your network, secure your setup, and consider the legal and ethical implications of launching a new cryptocurrency.

## License

CannacoinCash is released under the MIT License. See `COPYING` for more information.

---

**Disclaimer:** This guide is for educational purposes. Ensure compliance with all legal regulations and licensing agreements when forking and modifying open-source projects.

# Updated Bash Script

Below is the updated bash script incorporating all the changes and corrections:

```bash
#!/bin/bash

# Update and install dependencies
sudo apt update
sudo apt install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils git
sudo apt install -y libboost-all-dev
sudo apt install -y libdb-dev libdb++-dev
sudo apt install -y qtbase5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
sudo apt install -y libqrencode-dev
sudo apt install -y libminiupnpc-dev

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
mkdir ~/.cannacoincash
echo "rpcuser=user" > ~/.cannacoincash/cannacoincash.conf
echo "rpcpassword=pass" >> ~/.cannacoincash/cannacoincash.conf
echo "rpcallowip=127.0.0.1" >> ~/.cannacoincash/cannacoincash.conf
echo "rpcport=9387" >> ~/.cannacoincash/cannacoincash.conf
echo "server=1" >> ~/.cannacoincash/cannacoincash.conf
echo "daemon=1" >> ~/.cannacoincash/cannacoincash.conf

# Build the CannacoinCash software
./autogen.sh
./configure
make

# Start the CannacoinCash daemon
src/cannacoincashd -daemon

# Completion message
echo "CannacoinCash successfully built and the daemon is now running."
```

# Updates to the README.md

The `README.md` has been updated to reflect:

- Corrected `sed` commands to change the max supply and mining reward.
- Adjustments to the bash script sections.
- Clarification on terminology in the completion message.

---

**Note:** Always ensure that the `sed` commands match the exact lines in your source code files. If there are discrepancies, you may need to adjust the search patterns in the `sed` commands accordingly.

If you have any further questions or need additional assistance, feel free to ask!
