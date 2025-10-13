
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

--CREATE OR REPLACE FUNCTION qrdemo.next_id_seq(participant_id bigint, v_type varchar(64)) RETURNS bigint VOLATILE
--  LANGUAGE plpgSQL SECURITY INVOKER as $$
--DECLARE
-- v_r id_seq%ROWTYPE;
--BEGIN
-- -- 1) lock required tables
-- LOCK TABLE id_seq IN EXCLUSIVE MODE;
-- SELECT * from id_seq XRS into v_r WHERE
--    XRS.type=v_type and XSR.participant_id = participant_id;
-- -- 2) return null if no sequence
-- IF FOUND THEN
--  RETURN null;
-- END IF;
-- -- 3) create next id
-- IF v_r.lastid IS NULL THEN
--  v_r.lastid := v_r.start;
-- ELSE
--  v_r.lastid := v_r.lastid + v_r.step;
-- END IF;
-- -- 3) check that new id fit onto range (can be disabled for more performance)
-- IF (v_r.lastid < v_r.start OR v_r.lastid > v_r.rend) THEN
--  RETURN null;
-- END IF;
-- -- 4) update sequence
-- UPDATE id_seq XRS SET ts = NOW()
--  WHERE XRS.type =v_type ;
-- -- 5) finaly - return new id
-- RETURN v_r.lastid;
--END $$;

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 8' LANGUAGE SQL SECURITY INVOKER;