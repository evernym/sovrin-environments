#!/bin/bash

# NOTE: 'sovrin "new key" "exit"' fails with a stack trace on "exit" in
#       plenum.cli.cli.Exit. Don't use a -e on the #! above for this reason
#       only.

# Get this bash script's directory location
SOURCE="${BASH_SOURCE[0]}"
# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    # if $SOURCE was a relative symlink, we need to resolve it relative to the
    # path where the symlink file was located
    SOURCE="$DIR/$TARGET"
  fi
done
RDIR="$( dirname "$SOURCE" )"
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Make sure the indy_pool is up and running
sudo $DIR/indypool.py start

# Capture the pool_transactions_sandbox_genesis file from the indy_pool docker
# instance. This file contains the following information for each validator
# node:
# 1. IP address
# 2. Node port - inter-validator-node communication port
# 3. Client port - clients connect on this port
echo "Getting pool_transactions_sandbox_genesis file from indy_pool docker" \
  "container ..."
sudo docker exec -i indy_pool \
  sh -c "cat /home/indy/.indy/pool_transactions_sandbox_genesis" \
  > $DIR/pool_transactions_sandbox_genesis

# Generate a DID/verkey pair for use by DID2Ledger.py using newKey.py which
# was derived from sovrin_client/cli/cli.py
echo "Generating DID/verkey pair using sovrin $DIR/newKey.py..."
$DIR/newKey.py 2>/dev/null > $DIR/DID.verkey.pair

if [ $? -ne 0 ]; then
  echo "Failed to generate DID/verkey pair"
  exit 1
fi
DID=$(cat $DIR/DID.verkey.pair | grep "New DID is" | awk -F" " '{print $4}')
verkey=$(cat $DIR/DID.verkey.pair | grep "New verification key is" | \
  awk -F" " '{print $5}')
echo "Generated DID=$DID verkey=$verkey"

# Add the DID/verkey pair as a Trust Anchor
echo "Adding DID=$DID verkey=$verkey as a Trust Anchor ..."
command="$DIR/DID2Ledger.py $DIR/pool_transactions_sandbox_genesis $DID \
$verkey 000000000000000000000000Steward1 --role TRUST_ANCHOR" 

echo "Running command: $command"
$command
