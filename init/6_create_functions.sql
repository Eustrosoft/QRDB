-- Example of insert script
CREATE OR REPLACE FUNCTION qrdemo.create_qr(name varchar(64), description varchar(256))
  RETURNS VOID AS
$$
   INSERT INTO qrdemo.qr(name, description)
   VALUES ($1,$2);
$$
LANGUAGE sql STRICT;

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
