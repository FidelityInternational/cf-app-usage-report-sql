CF app-usage-report using SQL directly
======================================

This repository contain a rough implementation of a CF usage report implemented in SQL directly.

The goal of this repo is generate the reports as done in https://***REMOVED***/usage-reports/browse
in the most quick and simple way possible.

This scripts will rely on SQL to sum all the events from the table `app_usage_events` of the CF CloudController, which is
the data exposed by the endpoint [`/app_usage_events`](https://docs.cloudfoundry.org/running/managing-cf/usage-events.html).

Mathematics behind these queries
--------------------------------

The maths behind these queries are explained in this image:

![CF events aggregation](images/app_usage_maths.jpeg)

The idea is as follows, to sum the usage **per app `app_guid`**

 * Given:
	- a list of `N` events per app `E[app_guid]` ordered by creation time.
	- each event contains:
		- `current_usage_gb`: New usage in GB
		- `current_usage_instances`: New number of instances
		- `previous_usage_gb`: Old usage in GB
		- `previous_usage_instances`: Old number of instances
		- `created_at`: When the event is created
		- Stop events will have `#instances = 0`
	- `t_start` and `t_end`: times for the usage window to compute
	- `DT = t_end - t_start`

 * For each event `e[n]` in `E`, sum the result of:
	- Add the usage from `e[n].created_at` to `t_end`
		- `current_usage=(e[n].current_usage_gb * e[n].current_usage_gb) * (t_end - e(n).created_at)`
	- Substract the usage from `e(n).created_at` to `t_end`
		- `previous_usage=(e[n].previous_usage_gb * e[n].previous_usage_gb) * (t_end - e(n).created_at)`

 * Add the usage that has been carried on from events BEFORE `t_start`, for ALL the windows.
	- We know the previous usage because it the `previous_usage` for the first event `e[0]`
	- We must do this for all the window `DT` because we will substract the value later when computing `e[0]` in the iteration above.
	- `carried_usage = (e[0].previous_usage_gb *  e[n].previous_usage_gb) * (t_end - t_start)`


