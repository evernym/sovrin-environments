POOL_DATA_FILE="$1"
POOL_NETWORK_NAME="$2"

SCRIPT_DIR=$(dirname $0)
POOL_DATA=""

if [ "$CNT" = "--help" ]; then
        echo "Usage: $0 [<pool-data-file>] [<pool-network-name>]"
        exit 1
fi

if [ -z "$POOL_DATA_FILE" ]; then
	POOL_DATA_FILE="pool_data"
fi

if [ -z "$POOL_NETWORK_NAME" ]; then
	POOL_NETWORK_NAME="pool-network"
fi

echo "Reading pool data"
read -r POOL_DATA < $POOL_DATA_FILE
echo "Pool data is ${POOL_DATA}"
ORIGINAL_IFS=$IFS
IFS=","
POOL_DATA=($POOL_DATA)

echo "Stopping pool and removing containers"
for NODE_DATA in "${POOL_DATA[@]}"; do
	IFS=" "
	NODE_DATA=($NODE_DATA)
	IMAGE_NAME=${NODE_DATA[0]}
	NODE_IP=${NODE_DATA[1]}
	NODE_PORT=${NODE_DATA[2]}
	CLI_PORT=${NODE_DATA[3]}
	docker stop -t 15 $IMAGE_NAME
	docker rm $IMAGE_NAME
done
IFS=$ORIGINAL_IFS
echo "Pool stopped and all containers removed"

echo "Removing pool network"
docker network rm $POOL_NETWORK_NAME
echo "$POOL_NETWORK_NAME removed"
