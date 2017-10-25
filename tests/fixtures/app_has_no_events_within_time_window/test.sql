INSERT INTO bulk_organizations (
  guid,
  name
)
VALUES (
  'test_org_guid',
  'Test Org'
);

INSERT INTO bulk_organizations (
  guid,
  name
)
VALUES (
  'another_test_org_guid',
  'Another Test Org'
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
  '2017-10-20 18:00',                     -- created_at
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
  '923b2cdb-4dfb-4200-8941-20fe8ec88f65', -- guid
  '2017-10-19 14:00',                     -- created_at
  2,                                      -- instance_count
  1024,                                    -- memory_in_mb_per_instance
  'STARTED',                              -- state
  'another_app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'another_test_org_guid',
  'STOPPED',
  1024,
  2
);

INSERT INTO existing_apps (
    app_guid,
    app_name,
    space_guid,
    space_name,
    org_guid,
    memory,
    instances,
    state
) VALUES (
    'app_guid', -- app_guid,
    'Long_running_app', -- app_name,
    'space_guid', -- space_guid,
    'test space', -- space_name,
    'test_org_guid', -- org_guid,
    512, -- memory,
    1, -- instances,
    'STARTED' -- state
);

INSERT INTO existing_apps (
    app_guid,
    app_name,
    space_guid,
    space_name,
    org_guid,
    memory,
    instances,
    state
) VALUES (
    'another_app_guid', -- app_guid,
    '2nd-test-app', -- app_name,
    'space_guid', -- space_guid,
    'test space', -- space_name,
    'another_test_org_guid', -- org_guid,
    1024, -- memory,
    2, -- instances,
    'STARTED' -- state
);
