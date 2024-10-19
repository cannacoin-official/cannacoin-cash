#!/bin/bash

# CannacoinCash Mining Setup Script

# Exit immediately if a command exits with a non-zero status
set -e

# Update and install dependencies for mining software
sudo apt-get update
sudo apt-get install -y git build-essential automake libcurl4-openssl-dev libjansson-dev

# Clone and build cpuminer (CPU mining software)
cd ~
if [ ! -d "cpuminer" ]; then
    git clone https://github.com/pooler/cpuminer.git
fi
cd cpuminer
./autogen.sh
CFLAGS="-O3" ./configure
make
sudo make install

# Navigate back to the home directory
cd ~

# Set secure RPC credentials
RPCUSER="your_rpc_username"
RPCPASSWORD="your_rpc_password"

# Create or update the cannacoincash.conf file with RPC credentials
mkdir -p ~/.cannacoincash
cat > ~/.cannacoincash/cannacoincash.conf <<EOL
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcallowip=127.0.0.1
rpcport=9387
port=9388
listen=1
server=1
daemon=1
txindex=1
EOL

# Ensure the CannacoinCash daemon is running
if pgrep -x "cannacoincashd" > /dev/null
then
    echo "CannacoinCash daemon is already running."
else
    echo "Starting CannacoinCash daemon..."
    # Adjust the path to cannacoincashd if necessary
    if [ -f ~/CannacoinCash/src/cannacoincashd ]; then
        ~/CannacoinCash/src/cannacoincashd -daemon
    elif command -v cannacoincashd >/dev/null 2>&1; then
        cannacoincashd -daemon
    else
        echo "CannacoinCash daemon not found. Please ensure it is built and installed."
        exit 1
    fi
    sleep 10  # Wait for the daemon to start
fi

# Restart the CannacoinCash daemon to apply new configurations
if command -v cannacoincash-cli >/dev/null 2>&1; then
    cannacoincash-cli stop
    sleep 5
    cannacoincashd -daemon
else
    # Adjust the path to cannacoincash-cli and cannacoincashd if necessary
    ~/CannacoinCash/src/cannacoincash-cli stop
    sleep 5
    ~/CannacoinCash/src/cannacoincashd -daemon
fi
sleep 10  # Wait for the daemon to restart

# Start mining with cpuminer
echo "Starting mining operation..."

minerd --url=http://127.0.0.1:9387 --user=${RPCUSER} --pass=${RPCPASSWORD} --threads=$(nproc)

echo "Mining started. Press Ctrl+C to stop."
