ALTER TABLE participant ALTER COLUMN email DROP NOT NULL;
INSERT INTO dictionary(name, code, value, description)
values
('INPUT_URL', 'INPUT_TYPE', 'URL', 'Ссылка'),
('INPUT_PHONE_NUMBER', 'INPUT_TYPE', 'PHONE', 'Номер телефона'),
('INPUT_EMAIL', 'INPUT_TYPE', 'EMAIL', 'Email');
INSERT INTO settings(key, value)
values
('spring.datasource.max-active', '1'),
('spring.datasource.hikari.maximum-pool-size', '1')

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 3' LANGUAGE SQL SECURITY INVOKER;