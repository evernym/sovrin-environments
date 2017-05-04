IP="$1"
POOL_NETWORK_NAME="$2"

IMAGE_NAME="sovrinclientinteractive"
SCRIPT_DIR=$(dirname $0)

if [ "$CNT" = "--help" ]; then
        echo "Usage: $0 <client-ip> <pool-network-name>"
        return
fi

if [ -z "$POOL_NETWORK_NAME" ] || [ -z "$IP" ]; then
	echo "Invalid arguments. Try --help for usage."
	return
fi

echo "Removing old container"
docker rm -fv $IMAGE_NAME
echo "Starting interactive client $IMAGE_NAME $NODE_IP"
bash -c "docker run -it --rm -P --name=$IMAGE_NAME --ip=\"${NODE_IP}\" --network=$POOL_NETWORK_NAME --security-opt seccomp=unconfined --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro $IMAGE_NAME"
