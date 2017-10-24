INSERT INTO bulk_organizations (
  guid,
  name
)
VALUES (
  'test_org_guid',
  'Test Org'
);

INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  instance_count,
  memory_in_mb_per_instance,
  state,
  app_guid,
  app_name,
  space_guid,
  space_name,
  org_guid,
  previous_state,
  previous_memory_in_mb_per_instance,
  previous_instance_count
)
VALUES (
  '923b2cdb-4dfb-4200-8941-20fe8ec88f62', -- guid
  '2017-10-21 06:00',                     -- created_at
  1,                                      -- instance_count
  512,                                    -- memory_in_mb_per_instance
  'STARTED',                              -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'test_org_guid',
  'STOPPED',
  512,
  1
);

INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  instance_count,
  memory_in_mb_per_instance,
  state,
  app_guid,
  app_name,
  space_guid,
  space_name,
  org_guid,
  previous_state,
  previous_memory_in_mb_per_instance,
  previous_instance_count
)
VALUES (
  '923b2cdb-4dfb-4200-8941-20fe8ec88f64', -- guid
  '2017-10-21 12:00',                     -- created_at
  2,                                      -- instance_count
  1024,                                    -- memory_in_mb_per_instance
  'STARTED',                              -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'test_org_guid',
  'STARTED',
  512,
  1
);
