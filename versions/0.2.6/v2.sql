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
    email         VARCHAR(256) NOT NULL UNIQUE,
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
    file_name       VARCHAR(256) NOT NULL,
    file_type       VARCHAR(128), -- mime type for file
    extension       VARCHAR(64),
    active          BOOLEAN      NOT NULL DEFAULT TRUE,
    last_accessed   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    checksum        VARCHAR(128) NOT NULL,
    public          BOOLEAN      NOT NULL DEFAULT FALSE,
    storage_place   VARCHAR(64)  NOT NULL DEFAULT 'DB', -- storage type, maybe will store in S3 in future
    storage_path    VARCHAR(256),   -- path for local/S3 file storing type
    file_data       BYTEA,          -- file_data could be null due to stop process uploading - it could be reinit in future
    file_size       BIGINT, -- fast file length access, to not counting it from bytea directly
    
    CONSTRAINT check_storage_place   CHECK   (storage_place IN ('S3', 'DB', 'LOCAL')),

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

-- * referer not always could be a person, that created participant. Referer could be a friend, that asked to create a new account in system to take a benefit from this
-- ** there could be a situations, where not an admin creates new participant in system. After registration - administrator may approve or not activation for participant
