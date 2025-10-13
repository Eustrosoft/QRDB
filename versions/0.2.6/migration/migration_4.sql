set schema 'qrdemo';

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

alter table qrdemo.qr add action varchar(16) NULL;
alter table qrdemo.qr add redirect varchar(127) NULL;

ALTER TABLE qrdemo.file DROP CONSTRAINT check_file_data_size;
ALTER TABLE qrdemo.file DROP CONSTRAINT file_file_size_check;

-- SELECT NEEDED RANGE AND INSECT SEQUENCE
-- insert into qrdemo.qrange_seq(name, start, rend, step, lastid, ts) values ('QRDEMO', 17301504, 17367039, 16, 17301792, now());

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 4' LANGUAGE SQL SECURITY INVOKER;

