set schema 'qrdemo';

INSERT INTO qrdemo.dictionary(name, code, value, description)
	VALUES ('INPUT_TEXTAREA', 'INPUT_TYPE', 'TEXTAREA', 'Текст многострочный');

ALTER TABLE qrdemo.file DROP CONSTRAINT check_storage_place;
ALTER TABLE qrdemo.file ALTER checksum DROP NOT NULL;
ALTER TABLE qrdemo.file ALTER file_size DROP NOT NULL;
ALTER TABLE qrdemo.file ALTER file_data DROP NOT NULL;
ALTER TABLE qrdemo.file ALTER file_name DROP NOT NULL;
ALTER TABLE qrdemo.file ALTER storage_path DROP NOT NULL;
ALTER TABLE qrdemo.file ALTER storage_place DROP NOT NULL;
ALTER TABLE qrdemo.file ALTER file_size DROP NOT NULL;

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 5' LANGUAGE SQL SECURITY INVOKER;