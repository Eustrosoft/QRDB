ALTER TABLE qrdemo.registration_request DROP CONSTRAINT registration_request_email_key;

GRANT USAGE ON SCHEMA qrdemo TO qrdemo_readonly;
GRANT SELECT ON qrdemo.registration_request TO qrdemo_readonly;

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 13' LANGUAGE SQL SECURITY INVOKER;
