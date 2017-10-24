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
  '2017-10-21 14:00',                     -- created_at
  2,                                      -- instance_count
  1024,                                    -- memory_in_mb_per_instance
  'STOPPED',                              -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'test_org_guid',
  'STARTED',
  1024,
  2
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
  '923b2cdb-4dfb-4200-8941-20fe8ec88f66', -- guid
  '2017-10-21 18:00',                     -- created_at
  1,                                      -- instance_count
  2048,                                    -- memory_in_mb_per_instance
  'STARTED',                              -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'test_org_guid',
  'STOPPED',
  1024,
  2
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
  '923b2cdb-4dfb-4200-8941-20fe8ec88f67', -- guid
  '2017-10-21 19:00',                     -- created_at
  1,                                      -- instance_count
  2048,                                    -- memory_in_mb_per_instance
  'STOPPED',                              -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'test_org_guid',
  'STARTED',
  2048,
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
  '923b2cdb-4dfb-4200-8941-20fe8ec88f68', -- guid
  '2017-10-21 20:00',                     -- created_at
  1,                                      -- instance_count
  3072,                                    -- memory_in_mb_per_instance
  'STARTED',                              -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'test_org_guid',
  'STOPPED',
  2048,
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
  '123b2cdb-4dfb-4200-8941-20fe8ec88f62', -- guid
  '2017-10-20 17:55',                     -- created_at
  1,                                      -- instance_count
  512,                                    -- memory_in_mb_per_instance
  'STAGING_STARTED',                      -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'another_test_org_guid',
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
  '123b2cdb-4dfb-4200-8941-20fe8ec88f72', -- guid
  '2017-10-20 17:59',                     -- created_at
  1,                                      -- instance_count
  512,                                    -- memory_in_mb_per_instance
  'STAGING_STOPPED',                      -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'another_test_org_guid',
  'STAGING_STARTED',
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
  '123b2cdb-4dfb-4200-8941-20fe8ec88f82', -- guid
  '2017-10-20 18:00',                     -- created_at
  1,                                      -- instance_count
  512,                                    -- memory_in_mb_per_instance
  'BUILDPACK_SET',                        -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'another_test_org_guid',
  'STAGED',
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
  '123b2cdb-4dfb-4200-8941-20fe8ec88f92', -- guid
  '2017-10-20 18:00',                     -- created_at
  1,                                      -- instance_count
  512,                                    -- memory_in_mb_per_instance
  'STARTED',                              -- state
  'app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'another_test_org_guid',
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
  '123b2cdb-4dfb-4200-8941-20fe8ec88f64', -- guid
  '2017-10-21 12:00',                     -- created_at
  2,                                      -- instance_count
  1024,                                    -- memory_in_mb_per_instance
  'STARTED',                              -- state
  'another_app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'another_test_org_guid',
  'STARTED',
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
  '123b2cdb-4dfb-4200-8941-20fe8ec88f65', -- guid
  '2017-10-21 14:00',                     -- created_at
  2,                                      -- instance_count
  1024,                                    -- memory_in_mb_per_instance
  'STOPPED',                              -- state
  'another_app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'another_test_org_guid',
  'STARTED',
  1024,
  2
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
  '123b2cdb-4dfb-4200-8941-20fe8ec88f66', -- guid
  '2017-10-21 18:00',                     -- created_at
  1,                                      -- instance_count
  2048,                                    -- memory_in_mb_per_instance
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
  '123b2cdb-4dfb-4200-8941-20fe8ec88f67', -- guid
  '2017-10-21 19:00',                     -- created_at
  1,                                      -- instance_count
  2048,                                    -- memory_in_mb_per_instance
  'STOPPED',                              -- state
  'another_app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'another_test_org_guid',
  'STARTED',
  2048,
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
  '123b2cdb-4dfb-4200-8941-20fe8ec88f68', -- guid
  '2017-10-21 20:00',                     -- created_at
  1,                                      -- instance_count
  3072,                                    -- memory_in_mb_per_instance
  'STARTED',                              -- state
  'another_app_guid',                             -- app_guid
  'test app',
  'space_guid',
  'test space',
  'another_test_org_guid',
  'STOPPED',
  2048,
  1
);
