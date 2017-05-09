#!/bin/bash

IMAGE_NAME="$1"
IP="$2"
POOL_NETWORK_NAME="$3"

SCRIPT_DIR=$(dirname $0)

if [ "$CNT" = "--help" ]; then
        echo "Usage: $0 <image-name> <node-ip> <pool-network-name>"
        exit 1
fi

if [ -z "$POOL_NETWORK_NAME" ] || [ -z "$IMAGE_NAME" ] || [ -z "$IP" ]; then
	echo "Invalid arguments. Try --help for usage."
	exit 1
fi

echo "Removing old container"
docker rm -fv $IMAGE_NAME
echo "Starting node $IMAGE_NAME $NODE_IP"
docker run -td -P --memory="1512m" --name=$IMAGE_NAME --ip="${NODE_IP}" --network=$POOL_NETWORK_NAME --security-opt seccomp=unconfined --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro $IMAGE_NAME
docker exec -td $IMAGE_NAME systemctl start sovrin-node
echo "Node started"
