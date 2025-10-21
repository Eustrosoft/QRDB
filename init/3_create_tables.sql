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

CREATE TABLE IF NOT EXISTS qrdemo.h_form (
    data character varying(65536)
) INHERITS (qrdemo.h_entity);

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

CREATE TABLE IF NOT EXISTS qrdemo.h_qr_range (
    from_range	bigint,
	to_range	bigint,
	last_id		bigint
) INHERITS (qrdemo.h_entity);


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
);

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

