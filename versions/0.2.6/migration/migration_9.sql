
INSERT INTO qrdemo.dictionary(
	name, code, value, description)
	VALUES
	('MIME_TYPE_PDF', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'application/pdf', 'PDF format'),
	('MIME_TYPE_PNG', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'image/png', 'Image png format'),
	('MIME_TYPE_JPEG', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'image/jpeg', 'Image jpeg format'),
	('MIME_TYPE_JSON', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'application/json', 'Json format'),
	('MIME_TYPE_MP4', 'DOWNLOAD_ALLOWED_MIME_TYPE', 'video/mp4', 'MP4 video format');

CREATE OR REPLACE FUNCTION get_migration_ver() returns int as 'select 9' LANGUAGE SQL SECURITY INVOKER;