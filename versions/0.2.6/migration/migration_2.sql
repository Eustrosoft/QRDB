ALTER TABLE form_field ADD caption VARCHAR(256);
ALTER TABLE form_field ALTER COLUMN placeholder TYPE VARCHAR(1024);

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 2' LANGUAGE SQL SECURITY INVOKER;