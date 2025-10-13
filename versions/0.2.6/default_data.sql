set schema 'qrdemo';

delete from settings;
delete from dictionary;
delete from role where participant_id in (select id from participant where username='admin');;
delete from participant where username='admin';

INSERT INTO settings(key, value)
VALUES ('spring.servlet.multipart.max-file-size', '10MB'), -- max file upload size
       ('spring.servlet.multipart.enabled', 'true'), -- enabling file upload
	   ('spring.servlet.multipart.max-request-size', '10MB'), -- max request size
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

insert into dictionary(name, code, value, description)
values
('INPUT_TEXT', 'INPUT_TYPE', 'TEXT', 'Текст'),
('INPUT_NUMBER', 'INPUT_TYPE', 'NUMBER', 'Число'),
('INPUT_DATE', 'INPUT_TYPE', 'DATE', 'Дата');

-- password: 110
insert into participant(type, username, password, email)
values ('PT', 'admin', '$2a$10$cgSbX85roS0AjBDJzu3eZuFHnhCmlcgqGTPVz.TLG2eY.7DmWJUqK', 'admin@qrdemo.qxyz.ru');

insert into role (type, name, participant_id, active)
select 'RL', 'ROLE_ADMIN', id, TRUE from participant where username = 'admin';


