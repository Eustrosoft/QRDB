
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

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 10' LANGUAGE SQL SECURITY INVOKER;