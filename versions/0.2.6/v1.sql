-- Reference for the base class

 create table if not exists entity
 (
     id      bigserial NOT NULL UNIQUE,
     created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
     updated timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
     primary key (id)
 );

 create table if not exists role
 (
     name   varchar(64) not null,
     active boolean     not null default true,
     primary key (id)
 ) INHERITS (entity);

create table if not exists participant
(
    username      varchar(64) not null unique,
    password      varchar(128) not null,
    email         varchar(128) not null unique,
    referer       bigint,           -- refererId
    lei           varchar(256),
    address       varchar(128),
    site          varchar(512),
    organization  varchar(512),
    active        boolean     not null default true,
    banned        boolean     not null default false,
    settings      varchar(2048),
    banned_reason varchar(512),
    primary key (id)
) INHERITS (entity);

create table if not exists qr
(
    name        varchar(64),
    description varchar(512),
    code        bigint not null unique,
    data        varchar(65536),
    primary key (id)
) INHERITS (entity);

create table if not exists form_field
(
    name        varchar(64) not null,
    placeholder varchar(64),
    type        varchar(64) not null, -- text, color, file, number, date
    static      boolean     not null default true,
    public      boolean     not null default false,
    primary key (id)
) INHERITS (entity);

create table if not exists form_block
(
    name        varchar(64) not null,
    description varchar(512),
    primary key (id)
) INHERITS (entity);

create table if not exists form
(
    name        varchar(64) not null,
    description varchar(512),
    data varchar(65536),
    primary key (id)
) INHERITS (entity);

create table if not exists qr_range
(
    from_range bigint not null unique,
    to_range   bigint not null unique,
    primary key (id)
) INHERITS (entity);

-- connections

create table if not exists form_block_fields
(
    form_field_id bigserial not null,
    form_block_id bigserial not null,
    primary key (form_field_id, form_block_id),
    foreign key (form_field_id) references form_field (id),
    foreign key (form_block_id) references form_block (id)
);

create table if not exists form_blocks
(
    form_id       bigserial not null,
    form_block_id bigserial not null,
    primary key (form_id, form_block_id),
    foreign key (form_id) references form (id),
    foreign key (form_block_id) references form_block (id)
);

create table if not exists form_qr
(
    form_id bigserial not null,
    qr_id   bigserial not null,
    primary key (form_id, qr_id),
    foreign key (form_id) references form (id),
    foreign key (qr_id) references qr (id)
);

create table if not exists participant_qr
(
    participant_id bigserial not null,
    qr_id          bigserial not null,
    primary key (participant_id, qr_id),
    foreign key (participant_id) references participant (id),
    foreign key (qr_id) references qr (id)
);

create table if not exists participant_roles
(
    participant_id bigserial not null,
    role_id        bigserial not null,
    primary key (participant_id, role_id),
    foreign key (participant_id) references participant (id),
    foreign key (role_id) references role (id)
);

create table if not exists participant_qr_range
(
    participant_id bigserial not null,
    qr_range_id    bigserial not null,
    primary key (participant_id, qr_range_id),
    foreign key (participant_id) references participant (id),
    foreign key (qr_range_id) references qr_range (id)
);

create table if not exists participant_form
(
    participant_id bigserial not null,
    form_id        bigserial not null,
    primary key (participant_id, form_id),
    foreign key (participant_id) references participant (id),
    foreign key (form_id) references form (id)
);
