#!/bin/sh

# Goes to the CCDB database and dumps the app_usage_events and organizations
# tables as CSV to be imported later.

set -e -u

# Vars required for this script
: "${BOSH_HOST}"
: "${BOSH_VCAP_PASS}"
: "${BOSH_CLIENT_SECRET}"
: "${TARGET_DIRECTORY}"

# Suffix to add to the files generated
export DATA_FILE_SUFFIX="${DATA_FILE_SUFFIX:-}"

export BOSH_GW_USER=${BOSH_GW_USER:-vcap}
export BOSH_GW_HOST="${BOSH_GW_HOST:-${BOSH_HOST}}" # Assign the same to fail if missing
export BOSH_CLIENT="${BOSH_CLIENT:-director}"
export BOSH_ENVIRONMENT="${BOSH_ENVIRONMENT:-https://${BOSH_HOST}}"
export BOSH_CA_CERT="${BOSH_CA_CERT:-}"

# It would generate it if it does not exist
export BOSH_GW_PRIVATE_KEY="${BOSH_GW_PRIVATE_KEY:-$(pwd)/id_rsa}"

# Be sure there is no proxy stuff
export HTTP_PROXY=
export HTTPS_PROXY=
export http_proxy=
export https_proxy=

if [ ! -f id_rsa ]; then
    ssh-keygen -t rsa -N "" -f id_rsa -q
fi

ssh_cleanup() {
    sshpass -p "${BOSH_VCAP_PASS}" \
        ssh -o StrictHostKeyChecking=no \
        "${BOSH_GW_USER}"@"${BOSH_GW_HOST}" "sed -i \"/$(hostname)/d\" \$HOME/.ssh/authorized_keys"
}
ssh_init() {
    sshpass -p "${BOSH_VCAP_PASS}" \
        ssh-copy-id \
            -o StrictHostKeyChecking=no \
            -i "${BOSH_GW_PRIVATE_KEY}" "${BOSH_GW_USER}"@"${BOSH_GW_HOST}"
}
trap ssh_cleanup EXIT
ssh_init

PSQL_PATH=$(bosh ssh -d cf_databases ccdb/0 'find -L /var/vcap/packages -name psql -quit' | grep psql | awk '{print $4}')
if [ -n "${PSQL_PATH}" ]; then
  PSQL_PATH=$(echo "${PSQL_PATH}" | tr -dc '[:print:]')
  echo "PSQL Found at ${PSQL_PATH}"
else
  echo "Failed to find psql binary - Code might need fixing. Exiting!! "
  exit 1
fi

PSQL_URL=postgresql://localhost:3306/cloud_controller
bosh \
    ssh -d cf_databases ccdb/0 "
    sudo -u vcap -i \
    ${PSQL_PATH} ${PSQL_URL} \
    -c \"
        COPY (SELECT guid, created_at, instance_count, memory_in_mb_per_instance, state, app_guid, app_name, space_guid, space_name, org_guid, buildpack_guid, buildpack_name, package_state, parent_app_name, parent_app_guid, process_type, task_guid, task_name, package_guid, previous_state, previous_package_state, previous_memory_in_mb_per_instance, previous_instance_count FROM app_usage_events) TO '/tmp/app_usage_events.csv';
        COPY (SELECT guid, created_at, updated_at, name, billing_enabled, quota_definition_id, status, default_isolation_segment_guid FROM organizations) TO '/tmp/organizations.csv';

        CREATE TEMPORARY VIEW existing_apps AS
        SELECT
            app_guid,
            apps.name as app_name,
            processes.created_at,
            processes.updated_at,
            spaces.guid as space_guid,
            spaces.name as space_name,
            organizations.guid as org_guid,
            memory,
            instances,
            state
        FROM processes, apps, spaces, organizations
        WHERE processes.app_guid = apps.guid
        AND apps.space_guid = spaces.guid
        AND spaces.organization_id = organizations.id;

        COPY (SELECT * FROM existing_apps) TO '/tmp/existing_apps.csv';
    \";
"
mkdir -p "${TARGET_DIRECTORY}"
bosh scp -d cf_databases ccdb/0:/tmp/app_usage_events.csv "${TARGET_DIRECTORY}/app_usage_events${DATA_FILE_SUFFIX}.csv"
bosh scp -d cf_databases ccdb/0:/tmp/organizations.csv "${TARGET_DIRECTORY}/organizations${DATA_FILE_SUFFIX}.csv"
bosh scp -d cf_databases ccdb/0:/tmp/existing_apps.csv "${TARGET_DIRECTORY}/existing_apps${DATA_FILE_SUFFIX}.csv"
