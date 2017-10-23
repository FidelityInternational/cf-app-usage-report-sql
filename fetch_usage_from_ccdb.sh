#!/bin/sh

# Goes to the CCDB database and dumps the app_usage_events and organizations
# tables as CSV to be imported later.

# Vars required for this script
#
# REGION
# DEPLOY_ENV
# BOSH_CLIENT_SECRET
# BOSH_VCAP_PASS
# TARGET_DIRECTORY for the downloaded data
#

set -e -u

export BOSH_GW_USER=vcap
export BOSH_GW_HOST="${DEPLOY_ENV}-bosh.${REGION}.fid-intl.com"
export BOSH_GW_PRIVATE_KEY="$(pwd)/id_rsa"
export BOSH_CA_CERT="$(pwd)/fil-cacert.pem"
export BOSH_CLIENT=director
export BOSH_ENVIRONMENT=https://${DEPLOY_ENV}-bosh.${REGION}.fid-intl.com

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

PSQL_URL=postgresql://localhost:3306/cloud_controller
bosh \
    ssh -d cf_databases ccdb/0 "
    sudo -u vcap -i \
    /var/vcap/packages/postgres-9.6.3/bin/psql ${PSQL_URL} \
    -c \"
        COPY (SELECT guid, created_at, instance_count, memory_in_mb_per_instance, state, app_guid, app_name, space_guid, space_name, org_guid, buildpack_guid, buildpack_name, package_state, parent_app_name, parent_app_guid, process_type, task_guid, task_name, package_guid, previous_state, previous_package_state, previous_memory_in_mb_per_instance, previous_instance_count FROM app_usage_events) TO '/tmp/app_usage_events.csv';
        COPY (SELECT guid, created_at, updated_at, name, billing_enabled, quota_definition_id, status, default_isolation_segment_guid FROM organizations) TO '/tmp/organizations.csv';

        CREATE TEMPORARY VIEW existing_apps AS
        SELECT
            app_guid,
            apps.name as app_name,
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
mkdir -p $TARGET_DIRECTORY
bosh scp -d cf_databases ccdb/0:/tmp/app_usage_events.csv ${TARGET_DIRECTORY}/app_usage_events_${REGION}_${DEPLOY_ENV}.csv
bosh scp -d cf_databases ccdb/0:/tmp/organizations.csv ${TARGET_DIRECTORY}/organizations_${REGION}_${DEPLOY_ENV}.csv
bosh scp -d cf_databases ccdb/0:/tmp/existing_apps.csv ${TARGET_DIRECTORY}/existing_apps_${REGION}_${DEPLOY_ENV}.csv