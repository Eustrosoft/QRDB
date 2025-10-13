set schema 'qrdemo';

INSERT INTO qrdemo.dictionary(
	name, code, value, description)
	VALUES ('CHUNK_SIZE', 'FILE_UPLOAD', '1048576', 'Chunk file size for chunks file upload');

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

insert into settings(key, value) values ('files.upload.chunks.maximum', '16');


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