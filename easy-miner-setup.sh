#!/bin/bash

# Install dependencies for mining software
sudo apt-get update
sudo apt-get install -y git build-essential automake libcurl4-openssl-dev

# Clone and build cpuminer (CPU mining software)
cd ~
git clone https://github.com/pooler/cpuminer.git
cd cpuminer
./autogen.sh
CFLAGS="-O3" ./configure
make
sudo make install

# Navigate back to the home directory
cd ~

# Ensure the CannacoinCash daemon is running
if pgrep -x "cannacoincashd" > /dev/null
then
    echo "CannacoinCash daemon is running."
else
    echo "Starting CannacoinCash daemon..."
    ~/CannacoinCash/src/cannacoincashd -daemon
    sleep 10  # Wait for the daemon to start
fi

# Create or update the cannacoincash.conf file with RPC credentials
mkdir -p ~/.cannacoincash
echo "rpcuser=user" > ~/.cannacoincash/cannacoincash.conf
echo "rpcpassword=pass" >> ~/.cannacoincash/cannacoincash.conf
echo "rpcallowip=127.0.0.1" >> ~/.cannacoincash/cannacoincash.conf
echo "rpcport=9387" >> ~/.cannacoincash/cannacoincash.conf
echo "server=1" >> ~/.cannacoincash/cannacoincash.conf
echo "daemon=1" >> ~/.cannacoincash/cannacoincash.conf

# Restart the CannacoinCash daemon to apply new configurations
~/CannacoinCash/src/cannacoincash-cli stop
~/CannacoinCash/src/cannacoincashd -daemon
sleep 10  # Wait for the daemon to restart

# Start mining with cpuminer
echo "Starting mining operation..."
minerd --url=http://localhost:9387 --user=user --pass=pass --threads=$(nproc)

echo "Mining started. Press Ctrl+C to stop."

# Keep the script running to maintain the mining process
while true; do
    sleep 60
done
