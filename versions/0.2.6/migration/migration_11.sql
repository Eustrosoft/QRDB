INSERT INTO qrdemo.settings(key, value) VALUES ('spring.mvc.pathmatch.matching-strategy', 'ant_path_matcher');

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 11' LANGUAGE SQL SECURITY INVOKER;
