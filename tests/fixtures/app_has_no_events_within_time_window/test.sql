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

/*
 *          /--------- events ----------\
 *
 *   < t20  |   t20 |  t21    |   t22   | > t22
 *    ------|-------|---------|---------|--------
 *          |  a !a |  b !b   |   c !c  |
 *          |  d    |         |         |
 *          |       |  e      |         |
 *          |       |         |   f     |
 *          |  g    |         |   !g    |
 *      h   |       |         |         |   i
 *
 *
 * Running: d e f h i
 *
 *  - h is not in events, running since 17th
 *  - i is not in events, but running since 23st
 *
 * Charged by:
 * - b = 6 GB/h
 * - d = 24 GB/h
 * - e = 12 GB/h
 * - g = 24 GB/h
 * - h = 24 GB/h
 */

CREATE SEQUENCE event_id;

-- Case app a
INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-20 12:00',
  'STARTED', 1, 1024,
  'app_a_guid', 'app_a',
  'space_guid', 'test space', 'test_org_guid',
  'STOPPED', 1, 1024
);


INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-20 18:00',
  'STOPPED', 1, 1024,
  'app_a_guid', 'app_a',
  'space_guid', 'test space', 'test_org_guid',
  'STARTED', 1, 1024
);


-- Case app b
INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-21 12:00',
  'STARTED', 1, 1024,
  'app_b_guid', 'app_b',
  'space_guid', 'test space', 'test_org_guid',
  'STOPPED',1, 1024
);


INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-21 18:00',
  'STOPPED',1, 1024,
  'app_b_guid', 'app_b',
  'space_guid', 'test space', 'test_org_guid',
  'STARTED', 1, 1024
);


-- Case app c
INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-22 12:00',
  'STARTED', 1, 1024,
  'app_c_guid', 'app_c',
  'space_guid', 'test space', 'test_org_guid',
  'STOPPED', 1, 1024
);


INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-22 18:00',
  'STOPPED', 1, 1024,
  'app_c_guid', 'app_c',
  'space_guid', 'test space', 'test_org_guid',
  'STARTED', 1, 1024
);

-- Case app d
INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-20 12:00',
  'STARTED', 1, 1024,
  'app_d_guid', 'app_d',
  'space_guid', 'test space', 'test_org_guid',
  'STOPPED',1, 1024
);

-- Case app e
INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-21 12:00',
  'STARTED', 1, 1024,
  'app_e_guid', 'app_e',
  'space_guid', 'test space', 'test_org_guid',
  'STOPPED', 1, 1024
);


-- Case app f
INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-22 12:00',
  'STARTED', 1, 1024,
  'app_f_guid', 'app_f',
  'space_guid', 'test space', 'test_org_guid',
  'STOPPED', 1, 1024
);

-- Case app g
INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-20 12:00',
  'STARTED', 1, 1024,
  'app_g_guid', 'app_g',
  'space_guid', 'test space', 'test_org_guid',
  'STOPPED', 1, 1024
);

INSERT INTO bulk_app_usage_events (
  guid,
  created_at,
  state, instance_count, memory_in_mb_per_instance,
  app_guid, app_name,
  space_guid,space_name,org_guid,
  previous_state, previous_instance_count, previous_memory_in_mb_per_instance
)
VALUES (
  nextval('event_id')::text,
  '2017-10-22 18:00',
  'STOPPED', 1, 1024,
  'app_g_guid', 'app_g',
  'space_guid', 'test space', 'test_org_guid',
  'STARTED', 1, 1024
);

-- Running apps
-- app_d
INSERT INTO existing_apps (
  app_guid, app_name,
  created_at,
  updated_at,
  space_guid, space_name, org_guid,
  state, instances, memory
) VALUES (
  'app_d_uid', 'app_d',
  '2017-10-21 12:00', -- created_at
  NULL, -- updated_at
  'space_guid', 'test space', 'test_org_guid',
  'STARTED', 1, 1024
);

-- app_e
INSERT INTO existing_apps (
  app_guid, app_name,
  created_at,
  updated_at,
  space_guid, space_name, org_guid,
  state, instances, memory
) VALUES (
  'app_e_uid', 'app_e',
  '2017-10-22 12:00', -- created_at
  NULL, -- updated_at
  'space_guid', 'test space', 'test_org_guid',
  'STARTED', 1, 1024
);

-- app_f
INSERT INTO existing_apps (
  app_guid, app_name,
  created_at,
  updated_at,
  space_guid, space_name, org_guid,
  state, instances, memory
) VALUES (
  'app_f_uid', 'app_f',
  '2017-10-23 12:00', -- created_at
  NULL, -- updated_at
  'space_guid', 'test space', 'test_org_guid',
  'STARTED', 1, 1024
);

-- app_h
INSERT INTO existing_apps (
  app_guid, app_name,
  created_at,
  updated_at,
  space_guid, space_name, org_guid,
  state, instances, memory
) VALUES (
  'app_h_uid', 'app_h',
  '2017-10-10 12:00', -- created_at
  '2017-10-18 12:00', -- updated_at
  'space_guid', 'test space', 'test_org_guid',
  'STARTED', 1, 1024
);

-- app_i
INSERT INTO existing_apps (
  app_guid, app_name,
  created_at,
  updated_at,
  space_guid, space_name, org_guid,
  state, instances, memory
) VALUES (
  'app_i_uid', 'app_i',
  '2017-10-09 12:00', -- created_at
  '2017-10-23 12:00', -- updated_at
  'space_guid', 'test space', 'test_org_guid',
  'STARTED', 1, 1024
);

