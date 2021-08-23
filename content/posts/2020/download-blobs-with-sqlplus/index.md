---
title: Download BLOBs with SQL*Plus
description: New version of PL/SQL Export Utilities available
tags: [oracle, apex, plsql, script, sqlplus, version-control]
slug: download-blobs-with-sqlplus
aliases: [/posts/2020-01-01-download_blobs_with_sqlplus/]
publishdate: 2020-01-01
lastmod: 2020-10-26 16:43:00
---

Have you ever tried to spool/download BLOBS with SQL\*Plus? Some months ago I tried to find a way to download a collection of CLOBs or even better a zipped version of the collection as BLOB. I learned that BLOBs are not a valid datatype in SQL*Plus when it comes to the spool command. I found a way by putting the CLOBs into a global temporary table, creating an intermediate SQL script with tons of select and spool commands, and finally spooling the CLOBs one by one by calling the intermediate SQL script. It was working, but far from elegant. Also, when I was in the home office with a less powerful connection, it was slowing down the whole export process significantly.

If you are using PLEX (PL/SQL Export Utilities) and this sounds familiar to you - the described method was the default for exporting an APEX app or your schema DDL with the delivered export script templates.

If you have no idea what I am talking about: PLEX is a PL/SQL package that is able to export an Oracle APEX app, ORDS modules, all schema objects and table data into a nice directory structure in one go ready to use for version control. Check out the [project on GitHub][github] and this [blog post on how to get started][post].

But there is a better way: Simply convert the BLOB into a base64 encoded CLOB. I have no idea why this was not my first solution for the PLEX export templates. In the new version 2.1.0 of PLEX the templates are using this approach. Here is a simplified example.

File export.sql:

```sql
set verify off feedback off heading off
set trimout on trimspool on pagesize 0 linesize 5000 long 100000000 longchunksize 32767
whenever sqlerror exit sql.sqlcode rollback
variable contents clob
BEGIN
  :contents := plex.to_base64(plex.to_zip(plex.backapp(
    p_app_id               => 100,
    p_include_ords_modules => true,
    p_include_object_ddl   => false,
    p_include_data         => false,
    p_include_templates    => true)));
END;
/
set termout off
spool "app_100.zip.base64"
print contents
spool off
set termout on
```

Congratulations - You are the owner of a base64 encoded CLOB on your client disk. And now? Before you can unzip the file you need to decode it - depending on your operating system you can do this with your OS tools:

- Windows: `certutil -decode app_100.zip.base64 app_100.zip`
- Mac: `base64 -D -i app_100.zip.base64 -o app_100.zip`
- Linux: `base64 -d app_100.zip.base64 > app_100.zip`

Here a simple Windows batch file, which calls the SQL script above, decodes the file and deletes the base64 version.

File export.bat

```batch
echo exit | sqlplus -S demo/oracle@localhost:1521/xepdb1 @export.sql
certutil -decode app_100.zip.base64 app_100.zip
del app_100.zip.base64
```

The described method to download a BLOB is independent of the package PLEX - you only need a small helper function to encode the BLOB. I found an example provided by Tim Hall on his [Oracle Base site][oraclebase]. Thanks for sharing Tim!

```sql
CREATE OR REPLACE FUNCTION base64encode(p_blob IN BLOB)
  RETURN CLOB
-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/miscellaneous/base64encode.sql
-- Author       : Tim Hall
-- Description  : Encodes a BLOB into a Base64 CLOB.
-- Last Modified: 09/11/2011
-- -----------------------------------------------------------------------------------
IS
  l_clob CLOB;
  l_step PLS_INTEGER := 12000; -- make sure you set a multiple of 3 not higher than 24573
BEGIN
  FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(p_blob) - 1 )/l_step) LOOP
    l_clob := l_clob || UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(DBMS_LOB.substr(p_blob, l_step, i * l_step + 1)));
  END LOOP;
  RETURN l_clob;
END;
/
```

This function is included in the newest version of PLEX (named to_base64) - you can download PLEX [here][download].

Happy scripting, exporting and version controlling :-)

Ottmar

[download]: https://github.com/ogobrecht/plex/releases/latest
[github]: https://github.com/ogobrecht/plex
[oraclebase]: https://oracle-base.com/dba/script?category=miscellaneous&file=base64encode.sql
[post]: /posts/2018-08-26-plex-plsql-export-utilities
