#!/bin/bash
#
# Sync clickhouse tables to bigquery.
#

set -o errexit
set -o nounset
set -o pipefail

ROOT=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd $ROOT

GCP_PROJECT=<project>
GCP_DATASET=<dataset>
GCP_DATESET_LOCATION=us

tables=(
    table
)

function table_exsts() {
    local table="$1"
    bq ls --project_id=$GCP_PROJECT --format=csv $GCP_DATASET | grep "$table" 2>/dev/null
}

function sync() {
    local table="$1"
    local tmpfile=$(mktemp)
    trap "test -f $tmpfile && rm $tmpfile" RETURN
    echo "Writing records to temporary file $tmpfile..."
    hack/clickhouse-cli.sh --query "select * from $table" --format CSVWithNames > $tmpfile
    if table_exsts "$table"; then
        bq rm -f --project_id=$GCP_PROJECT $GCP_DATASET.$table
    fi
    bq load --project_id=$GCP_PROJECT --location=$GCP_DATESET_LOCATION \
        --source_format=CSV \
        --autodetect \
        $GCP_PROJECT:$GCP_DATASET.$table \
        $tmpfile \
        schema/$table.json
}

for t in ${tables[@]}; do
    echo "info: syncing table $t from ClickHouse to BigQuery"
    sync "$t"
done
