CREATE OR REPLACE FUNCTION qrdemo.h2i(text) RETURNS bigint IMMUTABLE AS
$$select ('x'||lpad(translate($1,':- ',''),16,'0'))::bit(64)::int8$$
        LANGUAGE SQL SECURITY INVOKER;

select 'dev40 range: 0000:0103:0040:0000/20 from 0000:0103:0040:0000 to 0000:0103:004F:FFFF';
select qrdemo.h2i('0000:0103:0040:0000') "from", qrdemo.h2i('0000:0103:004F:FFFF') "to";
select 'use in dev40: ALTER SEQUENCE qrdemo.entity_id_seq MINVALUE ' || qrdemo.h2i('0000:0103:0040:0000') || ' MAXVALUE ' || qrdemo.h2i('0000:0103:004F:FFFF') || ' START ' || qrdemo.h2i('0000:0103:0040:0000') || ' RESTART ' || qrdemo.h2i('0000:0103:0040:0000');
select 'prod range: 0000:0103:0080:0000/20 from 0000:0103:0080:0000 to 0000:0103:008F:FFFF';
select qrdemo.h2i('0000:0103:0080:0000') "from", qrdemo.h2i('0000:0103:008F:FFFF') "to";
select 'use in prod: ALTER SEQUENCE qrdemo.entity_id_seq MINVALUE ' || qrdemo.h2i('0000:0103:0080:0000') || ' MAXVALUE ' || qrdemo.h2i('0000:0103:004F:FFFF') || ' START ' || qrdemo.h2i('0000:0103:0080:0000') || ' RESTART ' || qrdemo.h2i('0000:0103:0080:0000');
