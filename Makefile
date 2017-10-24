POSTGRES_DOCKER_IMAGE:=postgres:9.6.3-alpine
PWD:=$(shell pwd)
USAGE_SQL_FILE:=./load_usage_from_csv_into_sql.sql

help:
	@grep -E '^[a-zA-Z0-9_-]+:[^=].*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "Parameters:"
	@grep -E '^[a-zA-Z0-9_-]+:=.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = "#?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: download_usage restart_postgresql init_schema load_data_on_psql generate_report_on_psql stop_postgresql ### Do all: download data, generate report

download_usage: ### Download all the usage data from every environment using bosh2+ssh
	time \
	./download_all_usage.sh uk
	ls -l data/

restart_postgresql: stop_postgresql ### Restart a postgresql server on docker
	docker run -d \
		-v "${PWD}:/workdir" \
		-w /workdir \
		--name report-postgres \
		"${POSTGRES_DOCKER_IMAGE}"
	@echo "Waiting for postgresql to start"
	@sleep 10

stop_postgresql: ### Stop the postgresql server on docker
	if [ -n "$$(docker ps -q -f name=report-postgres)" ]; then \
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
	time \
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
