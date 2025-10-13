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
