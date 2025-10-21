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

-- history scripts
-- CREATE TRIGGER qrdemo_qr_audit_trig AFTER INSERT OR DELETE OR UPDATE ON qrdemo.qr FOR EACH ROW EXECUTE FUNCTION qrdemo.do_h_qr();

-- CREATE TRIGGER qrdemo_file_audit_trig AFTER INSERT OR DELETE OR UPDATE ON qrdemo.file FOR EACH ROW EXECUTE FUNCTION qrdemo.do_h_file();
