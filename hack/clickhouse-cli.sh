#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

source $ROOT/hack/lib.sh

CLICKHOUSE_CLIENT_DIR=$ROOT/data/clickhouse-client

test -d $CLICKHOUSE_CLIENT_DIR || mkdir -p $CLICKHOUSE_CLIENT_DIR
touch $CLICKHOUSE_CLIENT_DIR/.clickhouse-client-history

docker_args=(
    --user $(id -u):$(id -g)
    -v $CLICKHOUSE_CLIENT_DIR/.clickhouse-client-history:/.clickhouse-client-history
    -v "$ROOT":/billing \
    -w /billing \
    --net host
	--rm
)

if [ -t 1 ]; then
	# Allocate a pseudo-TTY when the STDIN is a terminal
	docker_args+=(-it)
fi

args=(
	--host 127.0.0.1
	--database bill
)
if [ $# -gt 0 ]; then
    args+=("$@")
fi

docker run \
	"${docker_args[@]}" \
    clickhouse/clickhouse-client:$CLICKHOUSE_VERSION \
    "${args[@]}"
