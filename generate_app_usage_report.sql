/*
 * This file is a PoC of how to generate a CVS file from the \
 * app_usage_events of the cloudfoundry CCDB.
 *
 * See the comment in each operation that explains the maths.
 *
 * How to use it?
 * --------------
 *
 * You can easily and safely run this by exporting some tables from
 * ccdb and importing it in a postgresql:
 *
 * 1. Dump the tables from CCDB:
 *
 *    PSQL_URL=postgresql://localhost:3306/cloud_controller
 *    bosh ssh -d cf_databases ccdb/0 " \
 *      sudo -u vcap -i \
 *      /var/vcap/packages/postgres-9.6.3/bin/pg_dump ${PSQL_URL} \
 *       --not-owner \
 *       --disable-triggers \
 *       --no-privileges \
 *       -t organizations -t app_usage_events | \
 *          gzip > /tmp/usage_dump.sql.gz
 *    "
 *
 *    bosh scp -d cf_databases ccdb/0:/tmp/usage_dump.sql.gz .
 *
 * 2. Run a docker and import that data
 *
 *    # Start a postgresql
 *    docker run -ti --name some-postgres postgres:9.6.3-alpine -d
 *
 *    # Import the data in the docker (also add the citext extension)
 *    docker run -i --rm --link some-postgres:postgres postgres:9.6.3-alpine psql -h postgres -U postgres -c 'CREATE EXTENSION citext;'
 *    gunzip -c usage_dump.sql.gz | docker run -i --rm --link some-postgres:postgres postgres:9.6.3-alpine psql -h postgres -U postgres
 *
 * 3. Run a psql and run the stuff below by copy&paste
 *
 *    docker run -ti --rm --link some-postgres:postgres postgres:9.6.3-alpine psql -h postgres -U postgres
 */

\timing

/*
 * Create a view with the last events from the last month.
 * We get several info we would need later, like the org_guid, space, etc.
 *
 * We use  date_trunc('hour', now()) to work rounded to last hour.
 *
 * Additionally, we must filter and normalise the data:
 *  - We only consider STARTED and STOPPED for current and previous state
 *  - The STOPPED events should report 0 instances.
 *
 * Note: This is the perfect place to limit your searches for debuging.
 */
DROP MATERIALIZED VIEW IF EXISTS last_month_app_usage_events CASCADE;
CREATE MATERIALIZED VIEW last_month_app_usage_events AS
SELECT
    created_at,
    app_guid,
    org_guid,
    space_name,
    previous_state,
    previous_memory_in_mb_per_instance,
    CASE WHEN previous_state='STOPPED' THEN 0
    ELSE previous_instance_count
    END as previous_instance_count,
    state,
    memory_in_mb_per_instance,
    CASE WHEN state='STOPPED' THEN 0
    ELSE instance_count
    END as instance_count,
    FLOOR(EXTRACT(EPOCH FROM date_trunc('hour', now()) - created_at)) as dt,
    FLOOR(EXTRACT(EPOCH FROM created_at - (date_trunc('hour', now()) - interval '1 month'))) as pdt
FROM bulk_app_usage_events
WHERE created_at >= date_trunc('hour', now()) - interval '1 month'
AND created_at <= date_trunc('hour', now())
AND (state = 'STOPPED' OR state = 'STARTED')
AND (previous_state = 'STOPPED' OR previous_state = 'STARTED');


/*
 * Create a view with the last "metrics" of the events.
 * Each event has 2 metrics:
 *
 *  - One metric for the current usage, that will be added.
 *  - One metric for the previous usage, that will be substracted by setting instances == 0
 *
 */
DROP MATERIALIZED VIEW IF EXISTS app_usage_metrics CASCADE;
CREATE MATERIALIZED VIEW app_usage_metrics AS
SELECT
    created_at,
    app_guid,
    org_guid,
    space_name,
    previous_state as state,
    previous_memory_in_mb_per_instance as memory_in_mb_per_instance,
    - previous_instance_count as instance_count,  -- You substract the previous usage
    dt
FROM last_month_app_usage_events
UNION
SELECT
    created_at,
    app_guid,
    org_guid,
    space_name,
    state,
    memory_in_mb_per_instance,
    instance_count,
    dt
FROM last_month_app_usage_events;


/*
 * Add metrics to compute the carried usage of the app,
 * before the window being computed.
 *
 * We know the carried usage because it should be the reported "previous"
 * usage of the first event.
 *
 * The premise is that the app has been running since before the start of the
 * window. The first event reports that previous usage. For this event
 * the dt will be all the window (1 month) as it happens at the beginning.
 *
 * pdt will be 0.
 *
 * This query:
 *  - searches for the first event of each app
 *  - creates a new event e[-1] with e[-1].current = e[0].previous
 */
DROP MATERIALIZED VIEW IF EXISTS carried_app_usage_metrics CASCADE;
CREATE MATERIALIZED VIEW carried_app_usage_metrics AS
SELECT
    date_trunc('hour', now()) - interval '1 month' as created_at,
    app_usage_events.app_guid,
    app_usage_events.org_guid,
    app_usage_events.space_name,
    app_usage_events.previous_state as state,
    previous_memory_in_mb_per_instance as memory_in_mb_per_instance,
    CASE WHEN previous_state='STOPPED' THEN 0
    ELSE previous_instance_count
    END as instance_count,
    FLOOR(EXTRACT(EPOCH FROM INTERVAL '1 month')) as dt
FROM last_month_app_usage_events AS app_usage_events
INNER JOIN (
        SELECT app_guid, MIN(created_at) created_at
        FROM last_month_app_usage_events
        GROUP BY app_guid
    ) first_app_usage_events
ON app_usage_events.app_guid = first_app_usage_events.app_guid
AND app_usage_events.created_at = first_app_usage_events.created_at;


/*
 * We must also take into account all the apps that did not have any
 * event in the last period, but they are running anyway.
 *
 * We query the generate table existing_apps which contains info
 * of all the existing apps, and generate fake metrics in the start
 * of the window
 *
 * The premise is that the app with no events has been running since
 * before the start of the window. So we add a new metric.
 *
 * This query:
 *  - searches for any app that is STARTED with instances > 0
 *  - that has not events in the last month
 *  - creates a new event for this app at the begginging of the window
 */
DROP MATERIALIZED VIEW IF EXISTS carried_no_events_app_usage_metrics CASCADE;
CREATE MATERIALIZED VIEW carried_no_events_app_usage_metrics AS
SELECT
    date_trunc('hour', now()) - interval '1 month' as created_at,
    existing_apps.app_guid,
    existing_apps.org_guid,
    existing_apps.space_name,
    state,
    memory as memory_in_mb_per_instance,
    instances as instance_count,
    FLOOR(EXTRACT(EPOCH FROM INTERVAL '1 month')) as dt
FROM existing_apps
WHERE state = 'STARTED'
AND instances > 0
AND app_guid NOT IN (
    SELECT DISTINCT app_guid FROM last_month_app_usage_events
);

/*
 * Accumulate the MB/secs used for each app, from this event until
 * the end of our window.
 *
 * The calculation is: mem * instances * seconds
 *
 * We accumulate:
 *
 * - current_consumed: The usage of the app after this event until the
 *   end of the window.
 *
 * previous_consumed will be later be aggregated.
 */
DROP MATERIALIZED VIEW IF EXISTS per_app_usage_in_secs CASCADE;
CREATE MATERIALIZED VIEW per_app_usage_in_secs AS
SELECT
    app_guid,
    org_guid,
    space_name,
    sum(
        memory_in_mb_per_instance
        * instance_count
        * dt
    ) as current_consumed
FROM (
    SELECT * FROM app_usage_metrics
    UNION
    SELECT * FROM carried_app_usage_metrics
    UNION
    SELECT * FROM carried_no_events_app_usage_metrics
) AS app_usage_metrics
GROUP BY app_guid, org_guid, space_name;

/*
 * Sum and normalise up the actual usage for each app:
 *
 * - adds the usage after each event
 * - substracts the previous usage after each event
 * - adds the first known usage of the app
 *
 * Finally normalises everything to 1h and GB
 */
DROP MATERIALIZED VIEW IF EXISTS app_usage_gb_hour CASCADE;
CREATE MATERIALIZED VIEW app_usage_gb_hour AS
SELECT
    per_app_usage_in_secs.app_guid,
    per_app_usage_in_secs.org_guid,
    per_app_usage_in_secs.space_name,
    (
        per_app_usage_in_secs.current_consumed /
            EXTRACT(EPOCH FROM INTERVAL '1 hour')
    ) / 1024 as gb_hr
FROM per_app_usage_in_secs;

/*
 * Finally, aggregate all the data from all the apps in each space
 *
 * We get the organization name from the organization table
 *
 * Note: if the organization name is missing, the data will NOT be displayed
 * (inner join)
 */
CREATE OR REPLACE TEMPORARY VIEW month_usage_report AS
SELECT
    organizations.name as org_name,
    space_name,
    ROUND(SUM(gb_hr)::numeric, 2) total_gb_hr
FROM app_usage_gb_hour
INNER JOIN bulk_organizations AS organizations ON organizations.guid = app_usage_gb_hour.org_guid
WHERE organizations.name LIKE '%\_%'
GROUP BY organizations.name, space_name
ORDER BY organizations.name, space_name;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
/*
 * Refresh the views to get the latest data
 */
REFRESH MATERIALIZED VIEW last_month_app_usage_events;
REFRESH MATERIALIZED VIEW app_usage_metrics;
REFRESH MATERIALIZED VIEW carried_app_usage_metrics;
REFRESH MATERIALIZED VIEW carried_no_events_app_usage_metrics;
REFRESH MATERIALIZED VIEW per_app_usage_in_secs;
REFRESH MATERIALIZED VIEW app_usage_gb_hour;

SELECT
    org_name as "App",
    space_name as "Space Name",
    total_gb_hr as "GB Hours"
FROM month_usage_report;

-- Write as CSV to stdout
-- \copy (SELECT org_name as "App", space_name as "Space Name", total_gb_hr as "GB Hours" FROM month_usage_report)  TO STDOUT WITH CSV HEADER;

--- Write as CSV file to a file
\copy (SELECT org_name as "App", space_name as "Space Name", total_gb_hr as "GB Hours" FROM month_usage_report)  TO 'data/report.csv' WITH CSV HEADER;
