-- create admin
-- password: 110
insert into participant(type, username, password, email)
values ('PT', 'admin', '$2a$10$cgSbX85roS0AjBDJzu3eZuFHnhCmlcgqGTPVz.TLG2eY.7DmWJUqK', 'admin@qrdemo.qxyz.ru');

-- represents already defined roles
insert into role (type, name, participant_id, active)
select 'RL', 'ROLE_ADMIN', id, TRUE from participant where username = 'admin';

-- Init settings
INSERT INTO settings(key, value)
VALUES ('spring.servlet.multipart.max-file-size', '16MB'), -- max file upload size
       ('spring.servlet.multipart.enabled', 'true'), -- enabling file upload
	   ('spring.servlet.multipart.max-request-size', '16MB'), -- max request size
	   ('jwt.secret', 'Jqwnjqnwje'), -- cookie secret
	   ('ranges.rangeStart', '1070000'),
	   ('ranges.rangeEnd', '107FFFF'),
	   ('ranges.codesForRange', '15'),
	   ('jwt.lifetime', '24h'); -- cookie lifetime

insert into dictionary(name, code, value, description)
values
('ROLE_ADMIN', 'ROLE', 'ROLE_ADMIN', 'Admin role for system'),
('ROLE_USER', 'ROLE', 'ROLE_USER', 'User role for system'),
('ROLE_SALESMAN', 'ROLE', 'ROLE_SALESMAN', 'Salesman role for system');

INSERT INTO settings(key, value)
VALUES ('ranges.rangeStart', '1070000'),
	   ('ranges.rangeEnd', '107FFFF'),
	   ('ranges.codesForRange', '15');

INSERT INTO dictionary(name, code, value, description)
values
('INPUT_TEXT', 'INPUT_TYPE', 'TEXT', 'Текст'),
('INPUT_NUMBER', 'INPUT_TYPE', 'NUMBER', 'Число'),
('INPUT_DATE', 'INPUT_TYPE', 'DATE', 'Дата'),
('INPUT_URL', 'INPUT_TYPE', 'URL', 'Ссылка'),
('INPUT_PHONE_NUMBER', 'INPUT_TYPE', 'PHONE', 'Номер телефона'),
('INPUT_EMAIL', 'INPUT_TYPE', 'EMAIL', 'Email'),
('INPUT_TEXTAREA', 'INPUT_TYPE', 'TEXTAREA', 'Текст многострочный'),
('JUMP_QRSVC', 'INPUT_TYPE', 'EDIT', 'Редактировать');

INSERT INTO settings(key, value)
values
('spring.datasource.max-active', '1'),
('spring.datasource.hikari.maximum-pool-size', '1'),
('spring.mvc.pathmatch.matching-strategy', 'ant_path_matcher'),
('files.upload.chunks.maximum', '16')

INSERT INTO qrdemo.dictionary(
	name, code, value, description)
	VALUES
	('MIME_TYPE_PDF', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'application/pdf', 'PDF format'),
	('MIME_TYPE_PNG', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'image/png', 'Image png format'),
	('MIME_TYPE_JPEG', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'image/jpeg', 'Image jpeg format'),
	('MIME_TYPE_JSON', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'application/json', 'Json format'),
	('MIME_TYPE_MP4', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'video/mp4', 'MP4 video format');


INSERT INTO qrdemo.dictionary (name, code, value, description)
values ('STD', 'QR_ACTION', 'STD', 'Стандартная обработка'),
    ('REDIRECT', 'QR_ACTION', 'REDIRECT', 'Перенаправление на указанную страницу'),
    ('REDIRECT_QR_SVC', 'QR_ACTION', 'REDIRECT_QR_SVC', 'Перенаправление на другой qr-сервис'),
    ('HIDE', 'QR_ACTION', 'HIDE', 'Не показывать карточку');

INSERT INTO qrdemo.dictionary(
	name, code, value, description)
	VALUES ('CHUNK_SIZE', 'FILE_UPLOAD', '1048576', 'Chunk file size for chunks file upload');