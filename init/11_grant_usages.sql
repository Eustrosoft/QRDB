-- сделанные изменения:
-- password set for qrdemo_readonly
GRANT USAGE ON SCHEMA qrdemo TO qrdemo_readonly ;
GRANT SELECT ON ALL TABLES IN SCHEMA qrdemo TO qrdemo_readonly;

GRANT USAGE ON SCHEMA qrdemo TO qrdemo_readonly;
GRANT SELECT ON qrdemo.registration_request TO qrdemo_readonly;
