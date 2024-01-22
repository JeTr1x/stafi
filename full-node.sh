#!/usr/bin/env bash

DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

cd $DIR

set -xe

RELAY_WS_PORT=19945
RELAY_RPC_PORT=19934
RELAY_P2P_PORT=31334

PARA_WS_PORT=19944
PARA_RPC_PORT=19933
PARA_P2P_PORT=31333

NODE_NAME="$1"
DOCKER_VERSION="${2:-v1.8.8}"
PARA_CHAIN="${3:-heiko}"
RELAY_CHAIN="${4:-kusama}"
VOLUME="/tmp"
BASE_PATH="/data"

if [ $# -lt 1 ]; then
  echo "help: ./fullnode.sh <NODE_NAME>" && exit 1
fi

CHECK_CONTAINER=$(docker container ls | grep $PARA_CHAIN-fullnode |awk '{print $1}')
if [ $CHECK_CONTAINER ]; then
  docker container stop $PARA_CHAIN-fullnode || true
  docker container rm $PARA_CHAIN-fullnode || true
fi

CHECK_VOLUME=$(docker volume ls | grep $VOLUME |awk '{print $2}')
if [ !$CHECK_VOLUME ]; then
  docker volume create $VOLUME || true
fi

docker run --restart=always --name $PARA_CHAIN-fullnode \
  -d \
  -p $PARA_WS_PORT:$PARA_WS_PORT \
  -p $PARA_RPC_PORT:$PARA_RPC_PORT \
  -p $PARA_P2P_PORT:$PARA_P2P_PORT \
  -p $RELAY_WS_PORT:$RELAY_WS_PORT \
  -p $RELAY_RPC_PORT:$RELAY_RPC_PORT \
  -p $RELAY_P2P_PORT:$RELAY_P2P_PORT \
  -v "$VOLUME:$BASE_PATH" \
  parallelfinance/parallel:$DOCKER_VERSION \
    -d $BASE_PATH \
    --chain=$PARA_CHAIN \
    --ws-port=$PARA_WS_PORT \
    --rpc-port=$PARA_RPC_PORT \
    --ws-external \
    --rpc-external \
    --rpc-cors all \
    --ws-max-connections 4096 \
    --pruning archive \
    --wasm-execution=compiled \
    --execution=wasm \
    --state-cache-size 0 \
    --listen-addr=/ip4/0.0.0.0/tcp/$PARA_P2P_PORT \
    --name=$NODE_NAME \
    --prometheus-external \
  -- \
    --chain=$RELAY_CHAIN \
    --ws-port=$RELAY_WS_PORT \
    --rpc-port=$RELAY_RPC_PORT \
    --ws-external \
    --rpc-external \
    --rpc-cors all \
    --ws-max-connections 4096 \
    --wasm-execution=compiled \
    --execution=wasm \
    --database=RocksDb \
    --state-cache-size 0 \
    --unsafe-pruning \
    --pruning=1000 \
    --listen-addr=/ip4/0.0.0.0/tcp/$RELAY_P2P_PORT \
    --name="${NODE_NAME}_Embedded_Relay"
