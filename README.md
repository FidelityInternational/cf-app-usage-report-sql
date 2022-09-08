CF app-usage-report using SQL directly
======================================

This repository contain a rough implementation of a CF usage report implemented in SQL directly.

The goal of this repo is generate the reports, as done in our private
git repostiory `usage-reports`, in the most quick and simple way possible:

* We rely on a series of SQL queries to sum all the events from a copy of the data from the table `app_usage_events` of the CF CloudController, which is
the data exposed by the endpoint [`/app_usage_events`](https://docs.cloudfoundry.org/running/managing-cf/usage-events.html).

* We dump all the data from the environments using bosh2+ssh+psql and import it in a PostgresSQL running on docker.

Disclaimer
----------

Although we are using it to generate our real reports, we recommend you to review it before using it.

We share it because we were not able to find too much info about the topic,
and because the logic described in this repo might help other members of the
community.

Usage
-----

> Requirements: docker, pass, access to bosh in the network

To download the data and run the report use `make`:

* Run `make` to get help

For example:

```
# Download the CF data directly from ccdb
make download_usage render_load_usage_data_sql \
   BOSH_HOST=.... BOSH_CLIENT_SECRET=... BOSH_VCAP_PASS=....

# Load the data in a psql
make restart_postgresql
make init_schema load_data_on_psql

# Generate the report
make generate_report_on_psql stop_postgresql
```

Important files and how to work to modify this
-----------------------------------------------

The main files are:

* `Makefile`: All the tooling
* `fetch_usage_from_ccdb.sh`:
  * Not to be called directly
  * This script is intended to use in a docker with bosh2, sshpass, etc.
  * It would connect to a bosh2 to do `bosh ssh` into ccdb to export all data as CSV files.
* `generate_app_usage_report.sql`: Where all the logic resides, as described below. Writes to `data/report.csv`

To play around with the data in the `psql`:

 1. Download the data
 2. Start posgresql `make start_postgresql`
 3. Import the data `make load_data_on_psql`
 4. Start a psql: `make run_psql`
 5. Just copy&paste the queries from `generate_app_usage_report.sql`

Development tips
------------------

* Try to filter the number of events in the very first view `last_month_app_usage_events` to have manageable number of events.
* To get into ccdb: `bosh ssh  -d cf_databases ccdb/0` and `sudo -u vcap -i /var/vcap/packages/postgres-9.6.3/bin/psql postgresql://localhost:3306/cloud_controller`

Mathematics behind these queries
--------------------------------

The maths behind these queries are explained in this image:

![CF events aggregation](images/app_usage_maths.jpeg)

The idea is as follows, to sum the usage **per app `app_guid`**

* Given:
  * a list of `N` events per app `E[app_guid]` ordered by creation time.
  * each event contains:
    * `current_usage_gb`: New usage in GB
    * `current_usage_instances`: New number of instances
    * `previous_usage_gb`: Old usage in GB
    * `previous_usage_instances`: Old number of instances
    * `created_at`: When the event is created
    * Stop events will have `#instances = 0`
  * `t_start` and `t_end`: times for the usage window to compute
  * `DT = t_end - t_start`

* For each event `e[n]` in `E`, sum the result of:
  * Add the usage from `e[n].created_at` to `t_end`
    * `current_usage=(e[n].current_usage_gb * e[n].current_usage_gb) * (t_end - e(n).created_at)`
  * Subtract the usage from `e(n).created_at` to `t_end`
    * `previous_usage=(e[n].previous_usage_gb * e[n].previous_usage_gb) * (t_end - e(n).created_at)`

* Add the usage that has been carried on from events BEFORE `t_start`, for ALL the windows.
  * We know the previous usage because it the `previous_usage` for the first event `e[0]`
  * We must do this for all the window `DT` because we will subtract the value later when computing `e[0]` in the iteration above.
  * `carried_usage = (e[0].previous_usage_gb *  e[n].previous_usage_gb) * (t_end - t_start)`

See the code and comments in `./generate_app_usage_report.sql` to see how this is implemented.

Adding usage of existing apps without events
--------------------------------------------

It can happen that an app has been running constantly without any usage event in the last month.

We cover 3 cases:

* There is an event before the window: We pick the value of current usage of that event
* There is an event after the window: We pick the value of previous usage of that event
* There is no events at all: we create the table `existing_apps` to get a list of all
   the existing apps. We will add any app that has no events with a `create_at` before the window.
