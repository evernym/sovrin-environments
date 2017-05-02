CNT="$1"
IPS="$2"
CLI_CNT="$3"
START_PORT="$4"
BASE_IP="10.0.0."
BASE_NODE_NAME="Node"
SCRIPT_DIR=$(dirname $0)
POOL_DATA=""
POOL_DATA_FILE="pool_data"

if [ "$CNT" = "--help" ]; then
        echo "Usage: $0 <node-cnt> <pool-ips> <cli-cnt> <node-start-port>"
        return
fi

if [ -z "$CNT" ]; then
        CNT=4
fi

if [ -z "$CLI_CNT" ]; then
        CLI_CNT=10
fi

if [ -z "$START_PORT" ]; then
        START_PORT=9701
fi

if [ -z "$IPS" ]; then
	for i in `seq 1 $CNT`; do
		IP="${BASE_IP}${i}"
		IPS="${IPS},${IP}"
	done
	IPS=${IPS:1}
fi

echo "Creating pool of ${CNT} nodes with ips ${IPS}"
PORT=$START_PORT
ORIGINAL_IFS=$IFS
IFS=','
IPS_ARRAY=($IPS)
IFS=$ORIGINAL_IFS
for i in `seq 1 $CNT`; do
	NODE_NAME="${BASE_NODE_NAME}${i}"
	NPORT=$PORT
	((PORT++))
	CPORT=$PORT
	((PORT++))
	POOL_DATA="${POOL_DATA},${IPS_ARRAY[i-1]} $NPORT $CPORT"
	$SCRIPT_DIR/node_build.sh $NODE_NAME $NPORT $CPORT "${IPS}" $CNT $CLI_CNT $i
done
POOL_DATA=${POOL_DATA:1}

echo "Writing pool data $POOL_DATA to file $POOL_DATA_FILE"
echo "$POOL_DATA" > $POOL_DATA_FILE

echo "Pool created"
