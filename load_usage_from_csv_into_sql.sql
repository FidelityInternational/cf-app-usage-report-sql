DELETE from bulk_app_usage_events;
DELETE from bulk_organizations;

\copy bulk_app_usage_events FROM './data/app_usage_events_uk_np1.csv';
\copy bulk_app_usage_events FROM './data/app_usage_events_uk_np2.csv';
\copy bulk_app_usage_events FROM './data/app_usage_events_uk_p1.csv';
\copy bulk_app_usage_events FROM './data/app_usage_events_uk_p2.csv';

\copy bulk_organizations FROM './data/organizations_uk_np1.csv';
\copy bulk_organizations FROM './data/organizations_uk_np2.csv';
\copy bulk_organizations FROM './data/organizations_uk_p1.csv';
\copy bulk_organizations FROM './data/organizations_uk_p2.csv';
