#!/usr/bin awk -f
/^#/{next}
(length($1)==0){next}
BEGIN{
print "delete from qrdemo.dictionary where code = 'DOWNLOAD_ALLOWED_MIME_TYPE';"
}
{
 print "INSERT into qrdemo.dictionary values('" $1 "','DOWNLOAD_ALLOWED_MIME_TYPE','" $1 "','" $1 "');";
}
END{
print "select count(*) from qrdemo.dictionary where code = 'DOWNLOAD_ALLOWED_MIME_TYPE';"
}
