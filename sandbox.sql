SELECT
    app_guid,
    app_name,
    bulk_organizations.name as org_name,
    space_name,
    instances,
    memory
FROM existing_apps, bulk_organizations
WHERE state = 'STARTED'
AND existing_apps.org_guid = bulk_organizations.guid
AND instances > 0
AND app_guid NOT IN (
    SELECT DISTINCT app_guid FROM last_month_app_usage_events
)
ORDER BY app_name;

