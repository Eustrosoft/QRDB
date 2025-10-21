--select * from qrdemo.qr_range;
--select QRR.id, qr.participant_id, to_hex(max(code)),count(*) from qrdemo.qr QR, qrdemo.qr_range QRR where QR.code >= QRR.from_range and QR.code <= QRR.to_range  group by QRR.id, qr.participant_id;

--begin transaction;
--update qrdemo.qr_range QRR_u set last_id = (select max(code) from qrdemo.qr QR, qrdemo.qr_range QRR where QRR_u.id = QRR.id and QR.code >= QRR.from_range and QR.code <= QRR.to_range  group by QRR.id, qr.participant_id);
--rollback transaction;
--select * from qrdemo.qr_range;
--commit transaction;