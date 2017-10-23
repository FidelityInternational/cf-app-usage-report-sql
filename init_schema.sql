-- Usage events without the id
CREATE TABLE IF NOT EXISTS bulk_app_usage_events (
    guid text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    instance_count integer NOT NULL,
    memory_in_mb_per_instance integer NOT NULL,
    state text NOT NULL,
    app_guid text NOT NULL,
    app_name text NOT NULL,
    space_guid text NOT NULL,
    space_name text NOT NULL,
    org_guid text NOT NULL,
    buildpack_guid text,
    buildpack_name text,
    package_state text,
    parent_app_name text,
    parent_app_guid text,
    process_type text,
    task_guid text,
    task_name text,
    package_guid text,
    previous_state text,
    previous_package_state text,
    previous_memory_in_mb_per_instance integer,
    previous_instance_count integer
);
CREATE UNIQUE INDEX IF NOT EXISTS app_usage_events_guid_index ON bulk_app_usage_events USING btree (guid);
CREATE INDEX IF NOT EXISTS usage_events_created_at_index ON bulk_app_usage_events USING btree (created_at);

-- Orgs without the id
CREATE EXTENSION IF NOT EXISTS citext;
CREATE TABLE IF NOT EXISTS bulk_organizations (
    guid text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone,
    name citext NOT NULL,
    billing_enabled boolean DEFAULT false NOT NULL,
    quota_definition_id integer NOT NULL,
    status text DEFAULT 'active'::text,
    default_isolation_segment_guid text
);
CREATE UNIQUE INDEX IF NOT EXISTS organizations_guid_index ON bulk_organizations USING btree (guid);


