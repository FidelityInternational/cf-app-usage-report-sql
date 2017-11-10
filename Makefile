POSTGRES_DOCKER_IMAGE:=postgres:9.6.3-alpine
PWD:=$(shell pwd)

# Directory where to find the data files to import in DB
# Used to render the ${USAGE_SQL_FILE}
DATA_DIR:='./data'
# Suffix to match in datafiles. For instance: '*-prod'
DATA_FILE_SUFFIX_BLOB='*'
# SQL file that would Generated
USAGE_SQL_FILE:='./data/load_usage_from_csv_into_sql.sql'

help:
	@grep -E '^[a-zA-Z0-9_-]+:[^=].*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "Parameters:"
	@grep -E '^[a-zA-Z0-9_-]+:=.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = "#?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: download_usage restart_postgresql init_schema load_data_on_psql generate_report_on_psql stop_postgresql ### Do all: download data, generate report

test: ### Run the unit tests of the report
	./tests/report_generation.sh

download_usage: ### Download all the usage data from every environment using bosh2+ssh
	./download_all_usage.sh uk
	ls -l data/
	make render_load_usage_data_sql

render_load_usage_data_sql: ## Renders ${USAGE_SQL_FILE} based on the files in ${DATA_DIR} that match the ${DATA_FILE_SUFFIX_BLOB} pattern
	./render_load_usage_data_sql.sh ${DATA_DIR} ${DATA_FILE_SUFFIX_BLOB} | tee ${USAGE_SQL_FILE}

restart_postgresql: stop_postgresql ### Restart a postgresql server on docker
	docker run -d \
		-v "${PWD}:/workdir" \
		-w /workdir \
		--name report-postgres \
		"${POSTGRES_DOCKER_IMAGE}"
	@echo "Waiting for postgresql to start"
	@sleep 10

stop_postgresql: ### Stop the postgresql server on docker
	if [ -n "$$(docker ps -a -q -f name=report-postgres)" ]; then \
		docker rm -f report-postgres; \
	fi

reset_db:
	docker run -ti --rm \
		--link report-postgres:postgres \
		-v "${PWD}:/workdir" \
		-w /workdir \
		"${POSTGRES_DOCKER_IMAGE}" \
		psql -h postgres -U postgres template1 \
			-c "drop database postgres"

	docker run -ti --rm \
		--link report-postgres:postgres \
		-v "${PWD}:/workdir" \
		-w /workdir \
		"${POSTGRES_DOCKER_IMAGE}" \
		psql -h postgres -U postgres template1 \
			-c "create database postgres;"

init_schema: ### Init the schema
	@echo "Initializing the base schema"
	docker run -i --rm \
		--link report-postgres:postgres \
		-v "${PWD}:/workdir" \
		-w /workdir \
		"${POSTGRES_DOCKER_IMAGE}" \
		psql -h postgres -U postgres \
		-v ON_ERROR_STOP=1 \
		-f ./init_schema.sql

load_data_on_psql: ### load the usage data
	@echo "Importing existing usage data and orgs from environments"
	docker run -i --rm \
		--link report-postgres:postgres \
		-v "${PWD}:/workdir" \
		-w /workdir \
		"${POSTGRES_DOCKER_IMAGE}" \
		psql -h postgres -U postgres \
		-v ON_ERROR_STOP=1 \
		-f ${USAGE_SQL_FILE}

END_DATE:=NULL ### Valid values: "timestamp '2017-09-05'"
WINDOW:=NULL ### Valid values: "interval '1 week'"
generate_report_on_psql: ### Reload the logic and regenerate the report, with custom END_DATE and WINDOW
	@echo "Generating the report"
	docker run -i --rm \
		--link report-postgres:postgres \
		-v "${PWD}:/workdir" \
		-w /workdir \
		"${POSTGRES_DOCKER_IMAGE}" \
		psql -h postgres -U postgres \
		-v ON_ERROR_STOP=1 \
		-v end_date="${END_DATE}" \
		-v window="${WINDOW}" \
		-f ./generate_app_usage_report.sql

	@echo "Done! report in data/report.csv"

run_psql: ### Run a psql client against the database
	docker run -ti --rm \
		--link report-postgres:postgres \
		-v "${PWD}:/workdir" \
		-w /workdir \
		"${POSTGRES_DOCKER_IMAGE}" \
		psql -h postgres -U postgres
