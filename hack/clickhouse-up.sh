#!/bin/bash
#
# https://github.com/ClickHouse/ClickHouse/blob/master/docker/server/README.md
#

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

source $ROOT/hack/lib.sh

CLICKHOUSE_DIR=$ROOT/data/clickhouse
CLICKHOUSE_SERVER_DIR=$ROOT/data/clickhouse-server

test -d $CLICKHOUSE_DIR || mkdir -p $CLICKHOUSE_DIR
test -d $CLICKHOUSE_SERVER_DIR || mkdir -p $CLICKHOUSE_SERVER_DIR

docker run \
    --rm \
    --user $(id -u):$(id -g) \
    -p 8123:8123 \
    -p 9000:9000 \
    -v $CLICKHOUSE_DIR:/var/lib/clickhouse \
    -v $CLICKHOUSE_SERVER_DIR:/var/lib/clickhouse-server \
    --name taptap-bill-clickhouse \
    --ulimit nofile=262144:262144 \
    clickhouse/clickhouse-server:$CLICKHOUSE_VERSION
