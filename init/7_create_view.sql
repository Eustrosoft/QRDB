--create or replace view file_blob as select * from FBlob;
create or replace view file_blob as
select
 zoid, zrid, zver, ztov, zsid, zlvl, zpid, zuid,
 'N'::char(1) zsta,
 zdate, zdato, zuido, chunk, no, size, crc32
from FBlob where ZSTA = 'N';
