set schema 'qrdemo';

-- ADD EDIT TYPE Into dictionary
INSERT INTO qrdemo.dictionary (name, code, value, description) values ('JUMP_QRSVC', 'INPUT_TYPE', 'EDIT', 'Редактировать');

-- alert table column size
ALTER TABLE qrdemo.file ALTER COLUMN storage_path TYPE varchar(2048);

-- alert size of redirect attribute in qr table
ALTER TABLE qrdemo.qr ALTER COLUMN redirect TYPE varchar(2048);

-- add types of qr code/qr range in dictionary
INSERT INTO qrdemo.dictionary (name, code, value, description)
values ('STD', 'QR_ACTION', 'STD', 'Стандартная обработка'),
    ('REDIRECT', 'QR_ACTION', 'REDIRECT', 'Перенаправление на указанную страницу'),
    ('REDIRECT_QR_SVC', 'QR_ACTION', 'REDIRECT_QR_SVC', 'Перенаправление на другой qr-сервис'),
    ('HIDE', 'QR_ACTION', 'HIDE', 'Не показывать карточку');

UPDATE settings set value = '16MB' where key = 'spring.servlet.multipart.max-file-size';
UPDATE settings set value = '16MB' where key = 'spring.servlet.multipart.max-request-size';

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 6' LANGUAGE SQL SECURITY INVOKER;