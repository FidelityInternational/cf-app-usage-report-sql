#!/bin/sh
# Renders a SQL file to load the data files in ./data

DATA_DIR=${1:-./data}
DATA_FILE_SUFFIX_BLOB=${2:-*}

echo "DELETE from bulk_app_usage_events;"
for i in "${DATA_DIR}"/app_usage_events${DATA_FILE_SUFFIX_BLOB}.csv; do
    echo "\\copy bulk_app_usage_events FROM '$i';"
done
echo "DELETE from bulk_organizations;"
for i in "${DATA_DIR}"/organizations${DATA_FILE_SUFFIX_BLOB}.csv; do
    echo "\\copy bulk_organizations FROM '$i';"
done
echo "DELETE from existing_apps;"
for i in "${DATA_DIR}"/existing_apps${DATA_FILE_SUFFIX_BLOB}.csv; do
    echo "\\copy existing_apps FROM '$i';"
done

