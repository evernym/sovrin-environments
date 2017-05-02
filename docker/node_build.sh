NODE_NAME="$1"
NPORT="$2"
CPORT="$3"
IPS="$4"
CNT="$5"
CLI_CNT="$6"
NODE_NUM="$7"

SCRIPT_DIR=$(dirname $0)
NODE_IMAGE_TAG="$(echo "$NODE_NAME" | tr '[:upper:]' '[:lower:]')"
USER_ID="$(id -u)"

if [ "$NODE_NAME" = "--help" ] ; then
        echo "Usage: $0 <node-name> <node-port> <client-port> <cluster-ips> <node-cnt> <cli-cnt> <node-num>"
        return
fi

if [ -z "$NODE_NAME" ] || [ -z "$NPORT" ] || [ -z "$CPORT" ]; then
        echo "Incorrect input. Type $0 --help for help."
	return
fi

echo "Creating a new node ${NODE_NAME} ${NPORT} ${CPORT}"

echo "Setting up docker with systemd"
docker run --rm --privileged -v /:/host solita/ubuntu-systemd setup

echo "Building sovrinbase"
docker build -t 'sovrinbase' -f base.systemd.ubuntu.dockerfile $SCRIPT_DIR
echo "Building sovrincore for user ${USER_ID}"
docker build -t 'sovrincore' --build-arg uid=$USER_ID -f core.ubuntu.dockerfile $SCRIPT_DIR
echo "Building sovrinnode"
docker build -t 'sovrinnode' -f node.common.systemd.ubuntu.dockerfile $SCRIPT_DIR
echo "Building $NODE_IMAGE_TAG"
docker build -t "$NODE_IMAGE_TAG" --build-arg nodename=$NODE_NAME --build-arg nport=$NPORT --build-arg cport=$CPORT --build-arg ips=$IPS --build-arg nodenum=$NODE_NUM --build-arg nodecnt=$CNT --build-arg clicnt=$CLI_CNT -f node.systemd.ubuntu.dockerfile $SCRIPT_DIR

echo "Node ${NODE_NAME} ${NPORT} ${CPORT} created"
