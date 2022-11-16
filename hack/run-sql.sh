#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

source $ROOT/hack/lib.sh

sql=${1:-}
extra_args=${@:2}

if [ -z "$sql" ]; then
    echo "error: SQL is required"
    exit 1
fi

./hack/clickhouse-cli.sh --queries-file "$1" ${extra_args[@]}
