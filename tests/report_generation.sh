#!/usr/bin/env bash

set -e -u -o pipefail

PROJECT_DIR="$(dirname ${0})/.."
SCRIPT_DIR="$(dirname ${0})"
TEST_DIR="${PROJECT_DIR}/tests"

source "${SCRIPT_DIR}/common.sh"

# before all
export TEMPDIR_ROOT="$(mktemp -d)"
trap "{ rm -rf ${TEMPDIR_ROOT:-/tmp/dummy}; }" EXIT INT TERM

_before_each() {
	make -C "${PROJECT_DIR}" reset_db init_schema
	set -x
}

_after_each() {
	set +x
}

function usage_test() {
	make -C "${PROJECT_DIR}" load_data_on_psql USAGE_SQL_FILE="${TEST_DIR}/fixtures/$1/test.sql"
	make generate_report_on_psql END_DATE="timestamp '2017-10-22'" WINDOW="interval '1 day'"
	diff "${PROJECT_DIR}/data/report.csv" "${TEST_DIR}/fixtures/$1/expected_report.csv"
}

run usage_test single_stopped_started
run usage_test rolling_started_split_tier_events
run usage_test events_breaching_time_window_walls_all_tiers
run usage_test multiple_apps_with_mixed_event_types
run usage_test app_has_no_events_within_time_window
