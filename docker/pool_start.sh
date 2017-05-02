CNT="$1"
IPS="$2"
CLI_CNT="$3"
START_PORT="$4"
SCRIPT_DIR=$(dirname $0)

if [ "$CNT" = "--help" ]; then
        echo "Usage: $0 <node-cnt> <pool-ips> <cli-cnt> <node-start-port>"
        return
fi

echo "Creating pool"
$SCRIPT_DIR/pool_build.sh $CNT $IPS $CLI_CNT $START_PORT

echo "Starting pool"
