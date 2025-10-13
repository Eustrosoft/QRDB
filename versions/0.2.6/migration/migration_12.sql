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
GRANT SELECT ON ALL TABLES IN SCHEMA qrdemo TO qrdemo_readonly ;

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 12' LANGUAGE SQL SECURITY INVOKER;