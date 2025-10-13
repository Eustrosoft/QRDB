INSERT INTO settings(key, value)
VALUES ('ranges.rangeStart', '1070000'),
	   ('ranges.rangeEnd', '107FFFF'),
	   ('ranges.codesForRange', '15');

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 1' LANGUAGE SQL SECURITY INVOKER;