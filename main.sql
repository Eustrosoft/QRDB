--- Types:
--   - settings
--   - dictionary
--   - PARTICIPANT (PT)
--   - ROLE (RL)
--   - QR   (QR)
--   - QR_RANGE (QRR)
--   - FORM (FM)
--   - FORM_FIELD (FF)
--   - FILE (FILE)

set schema 'qrdemo';

CREATE TABLE if NOT EXISTS settings
(
    key     VARCHAR(128)    NOT NULL UNIQUE,
    value   VARCHAR(1024)   NOT NULL,
    PRIMARY KEY (key, value)
);

CREATE TABLE IF NOT EXISTS dictionary
(
    name        VARCHAR(64)     NOT NULL,
    code        VARCHAR(64)     NOT NULL,
    value       VARCHAR(128),
    description VARCHAR(128),
    PRIMARY KEY (name, code)
);

CREATE TABLE if NOT EXISTS entity
(
    id              BIGSERIAL   NOT NULL UNIQUE,
    participant_id  BIGINT,                   -- could be null due to administrator creation
    type            VARCHAR(16) NOT NULL,
    created         TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated         TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    name            VARCHAR(128),
    description     VARCHAR(512),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS participant
(
    username      VARCHAR(128) NOT NULL UNIQUE,
    password      VARCHAR(256) NOT NULL,
    email         VARCHAR(256) UNIQUE,
    referer       BIGINT,                        -- not always the same as participant_id here *
    lei           VARCHAR(256),
    address       VARCHAR(256),
    website       VARCHAR(256),
    organization  VARCHAR(256),
    active        BOOLEAN     NOT NULL DEFAULT TRUE,  -- user active or not (directly after registration) **
    banned        BOOLEAN     NOT NULL DEFAULT FALSE, -- is user banned for some reason
    settings      VARCHAR(2048),
    banned_reason VARCHAR(512),
    PRIMARY KEY (id)
) INHERITS (entity);

CREATE TABLE IF NOT EXISTS qr
(
    code        BIGINT  NOT NULL UNIQUE,
    action      VARCHAR(16),
    redirect    VARCHAR(2048),
    form_id     BIGINT, -- form, used by this qr, available empty
    data        VARCHAR(65536),
    PRIMARY KEY (id)
) INHERITS (entity);

CREATE TABLE IF NOT EXISTS qr_range
(
    from_range  BIGINT NOT NULL UNIQUE,
    to_range    BIGINT NOT NULL UNIQUE, -- maybe better to set bytes count
    PRIMARY KEY (id)
) INHERITS (entity);

CREATE TABLE IF NOT EXISTS form
(
    data VARCHAR(65536),    -- static data for each qr, that is using it
    PRIMARY KEY (id)
) INHERITS (entity);

CREATE TABLE IF NOT EXISTS form_field
(
    id             BIGSERIAL   NOT NULL UNIQUE,
    name           VARCHAR(128)    NOT NULL,
    caption        VARCHAR(256),
    participant_id BIGINT          NOT NULL,
    form_id        BIGINT          NOT NULL    REFERENCES form(id),
    field_order    INT             NOT NULL    DEFAULT 0,
    placeholder    VARCHAR(1024),
    field_type     VARCHAR(64)     NOT NULL,               -- text, color, file, number, date
    static         BOOLEAN         NOT NULL    DEFAULT TRUE,
    public         BOOLEAN         NOT NULL    DEFAULT FALSE,
    PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS file
(
    file_name       VARCHAR(256),
    file_type       VARCHAR(128), -- mime type for file
    extension       VARCHAR(64),
    active          BOOLEAN      NOT NULL DEFAULT TRUE,
    last_accessed   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    checksum        VARCHAR(128),
    public          BOOLEAN      NOT NULL DEFAULT FALSE,
    storage_place   VARCHAR(64)  DEFAULT 'DB', -- storage type, maybe will store in S3 in future
    storage_path    VARCHAR(2048),   -- path for local/S3 file storing type
    file_data       BYTEA,          -- file_data could be null due to stop process uploading - it could be reinit in future
    file_size       BIGINT, -- fast file length access, to not counting it from bytea directly

    PRIMARY KEY (id)
) INHERITS (entity);

CREATE TABLE IF NOT EXISTS role
(
    active         BOOLEAN      NOT NULL DEFAULT TRUE, -- way to block role by 'single-click'

    PRIMARY KEY (id)
) INHERITS (entity);

CREATE TABLE IF NOT EXISTS form_file
(
    form_id     bigint not null,
    file_id     bigint not null,
    primary key (form_id, file_id),
    foreign key (form_id) references form (id),
    foreign key (file_id) references file (id)
);

CREATE TABLE IF NOT EXISTS qr_file
(
    qr_id       bigint not null,
    file_id     bigint not null,
    primary key (qr_id, file_id),
    foreign key (qr_id)   references qr   (id),
    foreign key (file_id) references file (id)
);

CREATE TABLE IF NOT EXISTS qrdemo.h_entity (
    zsta character(1),
    zdato timestamp without time zone,
    id bigint NOT NULL,
    participant_id bigint,
    type character varying(16) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    name character varying(128),
    description character varying(512)
);

CREATE TABLE IF NOT EXISTS qrdemo.h_qr (
    code bigint NOT NULL,
    form_id bigint,
    data character varying(65536),
    action character varying(16),
    redirect character varying(2048)
) INHERITS (qrdemo.h_entity);

CREATE OR REPLACE FUNCTION qrdemo.do_h_qr() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        --
        -- Добавление строки в emp_audit, которая отражает операцию, выполняемую в emp;
        -- для определения типа операции применяется специальная переменная TG_OP.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO qrdemo.h_qr SELECT 'D', now(), OLD.*;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            IF (OLD = NEW) THEN
             RETURN NEW;
            END IF;
            INSERT INTO qrdemo.h_qr SELECT 'C', now(), OLD.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- возвращаемое значение для триггера AFTER игнорируется
    END;
$$;

CREATE TRIGGER qrdemo_qr_audit_trig AFTER INSERT OR DELETE OR UPDATE ON qrdemo.qr FOR EACH ROW EXECUTE FUNCTION qrdemo.do_h_qr();


CREATE TABLE IF NOT EXISTS qrdemo.h_form (
    data character varying(65536)
) INHERITS (qrdemo.h_entity);

CREATE OR REPLACE FUNCTION qrdemo.do_h_form() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        --
        -- Добавление строки в emp_audit, которая отражает операцию, выполняемую в emp;
        -- для определения типа операции применяется специальная переменная TG_OP.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO qrdemo.h_form SELECT 'D', now(), OLD.*;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            IF (OLD = NEW) THEN
             RETURN NEW;
            END IF;
            INSERT INTO qrdemo.h_form SELECT 'C', now(), OLD.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- возвращаемое значение для триггера AFTER игнорируется
    END;
$$;

CREATE TRIGGER qrdemo_form_audit_trig AFTER INSERT OR DELETE OR UPDATE ON qrdemo.form FOR EACH ROW EXECUTE FUNCTION qrdemo.do_h_form();

CREATE TABLE IF NOT EXISTS qrdemo.h_form_field (
    zsta character(1),
    zdato timestamp without time zone,
    id bigint NOT NULL,
    name character varying(128),
	participant_id bigint,
	form_id bigint,
	field_order int,
	placeholder character varying(1024),
	field_type character varying(64),
	static boolean,
	public boolean,
	caption character varying(256)
);

CREATE OR REPLACE FUNCTION qrdemo.do_h_form_field() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        --
        -- Добавление строки в emp_audit, которая отражает операцию, выполняемую в emp;
        -- для определения типа операции применяется специальная переменная TG_OP.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO qrdemo.h_form_field SELECT 'D', now(), OLD.*;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            IF (OLD = NEW) THEN
             RETURN NEW;
            END IF;
            INSERT INTO qrdemo.h_form_field SELECT 'C', now(), OLD.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- возвращаемое значение для триггера AFTER игнорируется
    END;
$$;

CREATE TRIGGER qrdemo_form_field_audit_trig AFTER INSERT OR DELETE OR UPDATE ON qrdemo.form_field FOR EACH ROW EXECUTE FUNCTION qrdemo.do_h_form_field();

CREATE TABLE IF NOT EXISTS qrdemo.h_qr_range (
    from_range	bigint,
	to_range	bigint,
	last_id		bigint
) INHERITS (qrdemo.h_entity);

CREATE OR REPLACE FUNCTION qrdemo.do_h_qr_range() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        --
        -- Добавление строки в emp_audit, которая отражает операцию, выполняемую в emp;
        -- для определения типа операции применяется специальная переменная TG_OP.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO qrdemo.h_qr_range SELECT 'D', now(), OLD.*;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            IF (OLD = NEW) THEN
             RETURN NEW;
            END IF;
            INSERT INTO qrdemo.h_qr_range SELECT 'C', now(), OLD.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- возвращаемое значение для триггера AFTER игнорируется
    END;
$$;

CREATE TRIGGER qrdemo_qr_range_audit_trig AFTER INSERT OR DELETE OR UPDATE ON qrdemo.qr_range FOR EACH ROW EXECUTE FUNCTION qrdemo.do_h_qr_range();

CREATE TABLE IF NOT EXISTS qrdemo.h_file (
    file_name       character varying(256),
    file_type       character varying(128),
    extension       character varying(64),
    active          boolean,
    last_accessed   timestamp,
    checksum        character varying(128),
    public          boolean,
    storage_place   character varying(64),
    storage_path    character varying(256),
    file_data       bytea,
    file_size       bigint
) INHERITS (qrdemo.h_entity);

CREATE OR REPLACE FUNCTION qrdemo.do_h_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        --
        -- Добавление строки в emp_audit, которая отражает операцию, выполняемую в emp;
        -- для определения типа операции применяется специальная переменная TG_OP.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO qrdemo.h_file SELECT 'D', now(), OLD.*;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            IF (OLD = NEW) THEN
             RETURN NEW;
            END IF;
            INSERT INTO qrdemo.h_file SELECT 'C', now(), OLD.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- возвращаемое значение для триггера AFTER игнорируется
    END;
$$;

CREATE TRIGGER qrdemo_file_audit_trig AFTER INSERT OR DELETE OR UPDATE ON qrdemo.file FOR EACH ROW EXECUTE FUNCTION qrdemo.do_h_file();

CREATE TABLE IF NOT EXISTS qrdemo.h_participant (
    username      character varying(128),
    password      character varying(256),
    email         character varying(256),
    referer       bigint,
    lei           character varying(256),
    address       character varying(256),
    website       character varying(256),
    organization  character varying(256),
    active        BOOLEAN,
    banned        BOOLEAN,
    settings      character varying(2048),
    banned_reason character varying(512)
) INHERITS (qrdemo.h_entity);

CREATE OR REPLACE FUNCTION qrdemo.do_h_participant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        --
        -- Добавление строки в emp_audit, которая отражает операцию, выполняемую в emp;
        -- для определения типа операции применяется специальная переменная TG_OP.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO qrdemo.h_participant SELECT 'D', now(), OLD.*;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            IF (OLD = NEW) THEN
             RETURN NEW;
            END IF;
            INSERT INTO qrdemo.h_participant SELECT 'C', now(), OLD.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- возвращаемое значение для триггера AFTER игнорируется
    END;
$$;

CREATE TRIGGER qrdemo_participant_audit_trig AFTER INSERT OR DELETE OR UPDATE ON qrdemo.participant FOR EACH ROW EXECUTE FUNCTION qrdemo.do_h_participant();

CREATE TABLE FBlob (
        ZOID    bigint NOT NULL, -- id
        ZRID    bigint NOT NULL, -- 1
        ZVER    bigint NOT NULL, -- 1
        ZTOV    bigint NOT NULL, -- 0 - actual, zver + 1 - archive
        ZSID    bigint NOT NULL, -- participant_id
        ZLVL    smallint NOT NULL, -- 31
        ZPID    bigint NOT NULL, -- 0
-- Added 18.03.2025
        ZUID    bigint NOT NULL, -- participant_id
        ZSTA    char(1) NOT NULL, -- 'N', 'C', 'D'
        ZDATE   timestamptz NOT NULL, -- Created date
        ZDATO   timestamptz NULL, -- Changed date
        ZUIDO   bigint NULL, -- User deleted id
--
        chunk   bytea NULL,
        no      bigint NULL,
        size    bigint NULL,
        crc32   bigint NULL,
        PRIMARY KEY (ZOID, ZRID, ZVER)
-- PRIMARY KEY (ZOID,ZRID,ZVER)
);

-- * referer not always could be a person, that created participant. Referer could be a friend, that asked to create a new account in system to take a benefit from this
-- ** there could be a situations, where not an admin creates new participant in system. After registration - administrator may approve or not activation for participant

delete from settings;
delete from dictionary;
delete from role where participant_id in (select id from participant where username='admin');;
delete from participant where username='admin';

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

INSERT INTO settings(key, value)
VALUES ('ranges.rangeStart', '1070000'),
	   ('ranges.rangeEnd', '107FFFF'),
	   ('ranges.codesForRange', '15');

INSERT INTO dictionary(name, code, value, description)
values
('INPUT_URL', 'INPUT_TYPE', 'URL', 'Ссылка'),
('INPUT_PHONE_NUMBER', 'INPUT_TYPE', 'PHONE', 'Номер телефона'),
('INPUT_EMAIL', 'INPUT_TYPE', 'EMAIL', 'Email');
INSERT INTO settings(key, value)
values
('spring.datasource.max-active', '1'),
('spring.datasource.hikari.maximum-pool-size', '1'),
('spring.mvc.pathmatch.matching-strategy', 'ant_path_matcher'),
('files.upload.chunks.maximum', '16')


CREATE OR REPLACE FUNCTION qrdemo.h2i(text) RETURNS bigint IMMUTABLE AS
$$select ('x'||lpad(translate($1,':- ',''),16,'0'))::bit(64)::int8$$
	LANGUAGE SQL SECURITY INVOKER;

CREATE TABLE if not exists qrange_seq (
    name varchar(64) NOT NULL,
	start	bigint NOT NULL,
	rend	bigint NOT NULL,
	step    int not null,
	lastid	bigint NULL,
	ts	timestamptz NOT NULL,
	descr varchar(1024) NULL,
	PRIMARY KEY (name)
);

CREATE OR REPLACE FUNCTION qrdemo.next_qrange( v_name varchar(64)) RETURNS bigint VOLATILE
  LANGUAGE plpgSQL SECURITY INVOKER as $$
DECLARE
 v_r qrange_seq%ROWTYPE;
BEGIN
 -- 1) lock required tables
 LOCK TABLE qrange_seq IN EXCLUSIVE MODE;
 SELECT * from qrange_seq XRS into v_r WHERE
    XRS.name=v_name and (XRS.lastid is NULL OR XRS.lastid<XRS.rend);
 -- 2) return null if no sequence
 IF NOT FOUND THEN
  RETURN null;
 END IF;
 -- 3) create next id
 IF v_r.lastid IS NULL THEN
  v_r.lastid := v_r.start;
 ELSE
  v_r.lastid := v_r.lastid + v_r.step;
 END IF;
 -- 3) check that new id fit onto range (can be disabled for more performance)
 IF (v_r.lastid < v_r.start OR v_r.lastid > v_r.rend) THEN
  RETURN null;
 END IF;
 -- 4) update sequence
 UPDATE qrange_seq XRS SET lastid = v_r.lastid, ts = NOW()
  WHERE XRS.name =v_name ;
 -- 5) finaly - return new id
 RETURN v_r.lastid;
END $$;

alter table qrdemo.qr_range add last_id bigint NULL;

--select * from qrdemo.qr_range;
--select QRR.id, qr.participant_id, to_hex(max(code)),count(*) from qrdemo.qr QR, qrdemo.qr_range QRR where QR.code >= QRR.from_range and QR.code <= QRR.to_range  group by QRR.id, qr.participant_id;

--begin transaction;
--update qrdemo.qr_range QRR_u set last_id = (select max(code) from qrdemo.qr QR, qrdemo.qr_range QRR where QRR_u.id = QRR.id and QR.code >= QRR.from_range and QR.code <= QRR.to_range  group by QRR.id, qr.participant_id);
--rollback transaction;
--select * from qrdemo.qr_range;
--commit transaction;

CREATE OR REPLACE FUNCTION qrdemo.next_qr( v_id bigint) RETURNS bigint VOLATILE
  LANGUAGE plpgSQL SECURITY INVOKER as $$
DECLARE
 v_r qr_range%ROWTYPE;
BEGIN
 -- 1) lock required tables
 LOCK TABLE qr_range IN EXCLUSIVE MODE;
 SELECT * from qr_range XRS into v_r WHERE
    XRS.id=v_id and (XRS.last_id is NULL OR XRS.last_id<XRS.to_range);
 -- 2) return null if no sequence
 IF NOT FOUND THEN
  RETURN null;
 END IF;
 -- 3) create next id
 IF v_r.last_id IS NULL THEN
  v_r.last_id := v_r.from_range;
 ELSE
  v_r.last_id := v_r.last_id + 1;
 END IF;
 -- 3) check that new id fit onto range (can be disabled for more performance)
 IF (v_r.last_id < v_r.from_range OR v_r.last_id > v_r.to_range) THEN
  RETURN null;
 END IF;
 -- 4) update sequence
 UPDATE qr_range XRS SET last_id = v_r.last_id, updated = NOW()
  WHERE XRS.id =v_id ;
 -- 5) finaly - return new id
 RETURN v_r.last_id;
END $$;

INSERT INTO qrdemo.dictionary(name, code, value, description)
	VALUES ('INPUT_TEXTAREA', 'INPUT_TYPE', 'TEXTAREA', 'Текст многострочный');

INSERT INTO qrdemo.dictionary (name, code, value, description) values ('JUMP_QRSVC', 'INPUT_TYPE', 'EDIT', 'Редактировать');

INSERT INTO qrdemo.dictionary (name, code, value, description)
values ('STD', 'QR_ACTION', 'STD', 'Стандартная обработка'),
    ('REDIRECT', 'QR_ACTION', 'REDIRECT', 'Перенаправление на указанную страницу'),
    ('REDIRECT_QR_SVC', 'QR_ACTION', 'REDIRECT_QR_SVC', 'Перенаправление на другой qr-сервис'),
    ('HIDE', 'QR_ACTION', 'HIDE', 'Не показывать карточку');

INSERT INTO qrdemo.dictionary(
	name, code, value, description)
	VALUES ('CHUNK_SIZE', 'FILE_UPLOAD', '1048576', 'Chunk file size for chunks file upload');

--create or replace view file_blob as select * from FBlob;
create or replace view file_blob as
select
 zoid, zrid, zver, ztov, zsid, zlvl, zpid, zuid,
 'N'::char(1) zsta,
 zdate, zdato, zuido, chunk, no, size, crc32
from FBlob where ZSTA = 'N';

CREATE OR REPLACE FUNCTION update_file_blob()
RETURNS TRIGGER AS
$$
DECLARE
--    v_id INT;
    r_h_f_b qrdemo.FBlob%ROWTYPE;
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- insert h_f_b
        r_h_f_b.ZOID= NEW.ZOID;
        r_h_f_b.ZRID= NEW.ZRID;
        r_h_f_b.ZVER= 1;
		r_h_f_b.ZTOV= 0;
		r_h_f_b.ZSID= NEW.ZSID;
		r_h_f_b.ZLVL= NEW.ZLVL;
		r_h_f_b.ZPID= NEW.ZPID;
		r_h_f_b.ZUID= NEW.ZUID;
        r_h_f_b.ZSTA= 'N';
        r_h_f_b.ZDATE= NOW();
        r_h_f_b.ZDATO=NULL;
    	r_h_f_b.ZUIDO= NEW.ZUIDO;
        r_h_f_b.chunk= NEW.chunk;
		r_h_f_b.no= NEW.no;
		r_h_f_b.size= NEW.size;
		r_h_f_b.crc32= NEW.crc32;
        INSERT INTO FBlob VALUES (r_h_f_b.*);
		RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
--        SELECT * FROM h_f_b INTO r_h_f_b where h_f_b.ZOID = NEW.id AND ZSTA='N';
--        IF r_h_f_b.data <> NEW.data OR ((r_h_f_b.data IS NULL OR NEW.data IS NULL) AND NOT COALESCE(r_h_f_b.data,NEW.data) IS NULL) THEN
--          UPDATE h_f_b SET ZSTA='C', ZDATO=NOW() where ZOID=r_h_f_b.ZOID AND ZVER=r_h_f_b.ZVER;
--          r_h_f_b.ZVER=r_h_f_b.ZVER+1;
--          r_h_f_b.ZDATE= NOW();
--          r_h_f_b.ZDATO= null;
--          r_h_f_b.data= NEW.data;
--          INSERT INTO h_f_b VALUES (r_h_f_b.*);
--        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE FBlob set ZSTA='D',ZDATO=NOW() where ZOID = OLD.ZOID AND ZRID = OLD.ZRID AND ZVER = OLD.ZVER and ZSTA='N';
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;
DROP TRIGGER instead_of_file_blob ON file_blob;
CREATE TRIGGER instead_of_file_blob
INSTEAD OF INSERT OR UPDATE OR DELETE
ON file_blob
FOR EACH ROW
EXECUTE FUNCTION update_file_blob();

CREATE TABLE IF NOT EXISTS qrdemo.h_file_before_fblob (
    id bigint NOT NULL,
    participant_id bigint,
    type character varying(16) NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    name character varying(128),
    description character varying(512),
    file_name       character varying(256),
    file_type       character varying(128),
    extension       character varying(64),
    active          boolean,
    last_accessed   timestamp,
    checksum        character varying(128),
    public          boolean,
    storage_place   character varying(64),
    storage_path    character varying(256),
    file_data       bytea,
    file_size       bigint
) ;
insert into qrdemo.h_file_before_fblob select * from file;

insert into fblob select id, 1, 1,0,participant_id, 31,0,participant_id,'N',created,null,participant_id,file_data,1,file_size,checksum::bigint+0 from file where not file_data is null;
-- alter table file drop file_data;
-- alter table h_file drop file_data;
CREATE TRIGGER qrdemo_file_audit_trig AFTER INSERT OR DELETE OR UPDATE ON qrdemo.file FOR EACH ROW EXECUTE FUNCTION qrdemo.do_h_file();

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 7' LANGUAGE SQL SECURITY INVOKER;


CREATE TABLE qrdemo.id_seq (
    participant_id       BIGINT         NOT NULL,
    type                 VARCHAR(64)    NOT NULL,
    current              INT            NOT NULL DEFAULT 0,
    max                  INT            NOT NULL DEFAULT 16,
    max_size_bytes       INT            DEFAULT NULL,
    valid_from           TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    valid_until          TIMESTAMP      DEFAULT NULL,
    assigned_at          TIMESTAMP      DEFAULT NULL,
    created              TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated              TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    primary key (participant_id, type)
);

-- Example of insert script
CREATE OR REPLACE FUNCTION qrdemo.create_qr(name varchar(64), description varchar(256))
  RETURNS VOID AS
$$
   INSERT INTO qrdemo.qr(name, description)
   VALUES ($1,$2);
$$
LANGUAGE sql STRICT;

-- Example of get script
CREATE OR REPLACE FUNCTION new_emp() RETURNS emp AS $$
    SELECT ROW('None', 1000.0, 25, '(2,2)')::emp;
$$ LANGUAGE SQL;

INSERT INTO qrdemo.dictionary(
	name, code, value, description)
	VALUES
	('MIME_TYPE_PDF', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'application/pdf', 'PDF format'),
	('MIME_TYPE_PNG', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'image/png', 'Image png format'),
	('MIME_TYPE_JPEG', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'image/jpeg', 'Image jpeg format'),
	('MIME_TYPE_JSON', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'application/json', 'Json format'),
	('MIME_TYPE_MP4', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'video/mp4', 'MP4 video format');


CREATE TABLE IF NOT EXISTS qrdemo.registration_request
(
    -- form registration data
    username      VARCHAR(128) UNIQUE,
    password      VARCHAR(256),
    email         VARCHAR(256) NOT NULL UNIQUE,

    -- user metadata
    ip_address    inet,
    user_agent    varchar(512),
    referrer_url  varchar(2048),

    -- user extra info
    first_name    varchar(128),
    last_name     varchar(128),
    website       VARCHAR(2048),
    organization  VARCHAR(256),
    phone_number  VARCHAR(32),
    country       VARCHAR(128),
    city          VARCHAR(128),

    -- request status and info
    status              VARCHAR(64) NOT NULL DEFAULT 'IN_WORK', -- Statuses: PENDING, IN_WORK, ACCEPTED, REJECTED
    status_msg          VARCHAR(256),
    registration_id     UUID        UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    -- reviewer info
    reviewed_by   bigint,
    reviewed_at   TIMESTAMP,

    PRIMARY KEY (id)
) INHERITS (entity);

CREATE OR REPLACE FUNCTION qrdemo.save_registration_request(
    p_username varchar(128),
    p_password varchar(256),
    p_email varchar(256),
    p_ip_address inet,
    p_user_agent varchar(512),
    p_referrer_url varchar(2048)
) RETURNS VARCHAR VOLATILE
	LANGUAGE plpgSQL SECURITY DEFINER as $$
DECLARE
    new_request_id UUID;
BEGIN
    INSERT INTO registration_request (
        type, username, password, email, ip_address,
        user_agent, referrer_url, status
    )
    VALUES (
        'REG', p_username, p_password, p_email, p_ip_address,
        p_user_agent, p_referrer_url, 'PENDING'
    ) RETURNING registration_id INTO new_request_id;

    RETURN new_request_id::text;
END $$;

CREATE OR REPLACE FUNCTION qrdemo.get_registration_request_details(
    p_registration_id UUID
) RETURNS TABLE(username VARCHAR, status VARCHAR, status_msg VARCHAR) STABLE
	LANGUAGE plpgSQL SECURITY DEFINER as $$
BEGIN
    RETURN QUERY
    SELECT rr.username, rr.status, rr.status_msg
    FROM qrdemo.registration_request as rr
    WHERE rr.registration_id = p_registration_id;
END $$;

CREATE OR REPLACE FUNCTION qrdemo.save_registration_request(
    p_first_name varchar(128),
    p_last_name varchar(128),
    p_email varchar(256),
    p_phone_number varchar(32),
    p_website varchar(2048),
    p_organization varchar(256),
    p_country varchar(128),
    p_city varchar(128),
    p_ip_address inet,
    p_user_agent varchar(512),
    p_referrer_url varchar(2048)
) RETURNS VARCHAR VOLATILE
	LANGUAGE plpgSQL SECURITY DEFINER as $$
DECLARE
    new_request_id UUID;
BEGIN
    INSERT INTO registration_request (
        type, first_name, last_name, email, phone_number,
        website, organization, country, city,
        ip_address, user_agent, referrer_url, status
    )
    VALUES (
        'REG', p_first_name, p_last_name, p_email,
        p_phone_number, p_website, p_organization, p_country, p_city,
        p_ip_address, p_user_agent, p_referrer_url, 'PENDING'
    ) RETURNING registration_id INTO new_request_id;

    RETURN new_request_id::text;
END $$;

CREATE OR REPLACE FUNCTION qrdemo.get_registration_request_details(
    p_registration_id UUID
) RETURNS TABLE(username VARCHAR, status VARCHAR, status_msg VARCHAR) STABLE
	LANGUAGE plpgSQL SECURITY DEFINER as $$
BEGIN
    RETURN QUERY
    SELECT rr.username, rr.status, rr.status_msg
    FROM qrdemo.registration_request as rr
    WHERE rr.registration_id = p_registration_id;
END $$;

ALTER TABLE registration_request ALTER COLUMN username DROP NOT NULL;
ALTER TABLE registration_request ALTER COLUMN password DROP NOT NULL;

-- сделанные изменения:
CREATE USER qrdemo_readonly LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER NOBYPASSRLS NOREPLICATION ;
-- password set for qrdemo_readonly
GRANT USAGE ON SCHEMA qrdemo TO qrdemo_readonly ;
GRANT SELECT ON ALL TABLES IN SCHEMA qrdemo TO qrdemo_readonly;

ALTER TABLE qrdemo.registration_request DROP CONSTRAINT registration_request_email_key;

GRANT USAGE ON SCHEMA qrdemo TO qrdemo_readonly;
GRANT SELECT ON qrdemo.registration_request TO qrdemo_readonly;