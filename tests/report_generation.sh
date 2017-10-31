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

function header_test() {
	test_name=single_stopped_started

	make -C "${PROJECT_DIR}" load_data_on_psql USAGE_SQL_FILE="${TEST_DIR}/fixtures/${test_name}/test.sql"
	make generate_report_on_psql END_DATE="timestamp '2017-10-22'" WINDOW="interval '1 day'"

	head -n 1 "${PROJECT_DIR}/data/report.csv"|
		grep -qe '^App,Space Name,Total GB Hours,0GB <= x <= 0.5GB,0.5GB < x <= 1GB,1GB < x <= 2GB,2GB < x$'
}

function usage_test() {
	test_name=$1

	make -C "${PROJECT_DIR}" load_data_on_psql USAGE_SQL_FILE="${TEST_DIR}/fixtures/${test_name}/test.sql"
	make generate_report_on_psql END_DATE="timestamp '2017-10-22'" WINDOW="interval '1 day'"

	# Use tail +2 to strip off the header of the CSV
	diff \
		<(tail +2 "${PROJECT_DIR}/data/report.csv") \
		<(tail +2 "${TEST_DIR}/fixtures/$1/expected_report.csv")
}

run header_test
run usage_test single_stopped_started
run usage_test rolling_started_split_tier_events
run usage_test events_breaching_time_window_walls_all_tiers
run usage_test multiple_apps_with_mixed_event_types
run usage_test app_has_no_events_within_time_window
