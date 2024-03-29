---
title: Erstellung schneller Insert-Skripte
description: PL/SQL Export Utilities können jetzt Tabellendaten als Insert Scripts exportieren
tags: [Oracle, Script, Generator]
slug: create-fast-insert-scripts
publishdate: 2021-01-31
lastmod: 2021-08-30 13:00:00
featured_image: indira-tjokorda-Y-VYK0SDLxs-unsplash.jpg
featured_image_alt: Sportler auf Inlineskates
featured_image_caption: Foto von Indira Tjokorda auf unsplash.com
---

Vor einigen Wochen habe ich eine neue Version meines [PLEX-Projekts](https://github.com/ogobrecht/plex) veröffentlicht. Ich habe die Möglichkeit verbessert, Tabellendaten als Insert-Skripte zu exportieren. Bisher war PLEX nur in der Lage, CSV-Daten zu exportieren. Der Grund dafür war, dass ich PLEX ursprünglich entwickelt habe, um die Einführung einer Versionskontrolle in Oracle-DB-Projekten zu beschleunigen, und die Möglichkeit CSV-Daten zu exportieren war dazu gedacht, Änderungen in Stammdatentabellen zu verfolgen.

Es stellte sich heraus, dass ein Kollege von mir wollte, dass PLEX für das initiale Deployment einer neuen Anwendung Insert-Skripte für alle Daten in allen Tabellen exportiert. Ich habe eine erste Version implementiert, war aber mit der Laufzeit der Insert-Skripte nicht zufrieden. Ich höre jetzt einige Leute argumentieren, dass es bessere Tools als Insert-Skripte für den Import größerer Datenmengen gibt - aber manchmal ist dies der einzige akzeptierte Weg, weil nur SQL*Plus zur Ausführung der Deployment-Skripte zur Verfügung steht...

Dann bin ich über einen älteren Beitrag von [Connor McDonald über die Erstellung schneller Insert-Skripte](https://connor-mcdonald.com/2019/05/17/hacking-together-faster-inserts/) gestolpert. Ich habe seine Performance-Hacks in PLEX integriert.

Ihr könnt sie wie folgt verwenden (siehe letzter Parameter):

```sql
DECLARE
  l_zip_file BLOB;
BEGIN
  l_zip_file := plex.to_zip(plex.backapp(
    p_app_id                   => 100,  -- parameter only available when APEX is installed
    p_include_ords_modules     => true, -- parameter only available when ORDS is installed
    p_include_object_ddl       => true,
    p_include_data             => true,
    p_data_as_of_minutes_ago   => 0,     -- Read consistent data with the resulting timestamp (SCN). Defaults to 0.
    p_data_max_rows            => 10000, -- Maximum number of rows per table. Defaults to 1000.
    p_data_table_name_like     => 'CAT\_%,USERS,ROLES,RIGHTS',
    p_data_table_name_not_like => '%\_HIST,LOGGER%',
    p_data_format              => 'insert:10'
  ));

  -- Do something with the zip file.
  -- Your code here...
END;
/
```

Der Parameter `p_data_format` ist neu und kann eine durch Komma getrennte Liste von Formaten enthalten - derzeit werden die Formate CSV und INSERT unterstützt. Ein Beispiel: `csv,insert` exportiert für jede Tabelle eine CSV-Datei und eine SQL-Datei mit Insert-Anweisungen. Für insert kann man auch  die Anzahl der Zeilen pro `insert all`-Anweisung angeben (Standardwert ist 20) - Beispiel: `csv,insert:10` oder `insert:5`.

Wie Ihr an dem Parameter `p_data_table_name_not_like => '%\_HIST,LOGGER%'` sehen könnt, akzeptiert PLEX auch Listen mit Like-Filtern. In unserem Beispiel wird `%\_HIST,LOGGER%` übersetzt in:

```sql
where ... 
  and (    table_name not like '%\_HIST' escape '\' 
       and table_name not like 'LOGGER%' escape '\'
       and ...
      )
```

Für den Parameter `p_data_table_name_like => 'CAT\_%,USERS,ROLES,RIGHTS'` werden die Tabellen folgendermaßen gefiltert:

```sql
where ... 
  and (   table_name like 'CAT\_%' escape '\' 
       or table_name like 'USERS'  escape '\' 
       or ...
      )
```

Es gibt einen guten Grund, warum die Voreinstellung des Parameters `p_data_max_rows` auf `1000` gesetzt ist - wenn Ihr keine Tabellennamenfilter angebt, werden alle Tabellen exportiert...

Die resultierenden Insert-Skripte sehen wie folgt aus:

```sql
-- Script generated by PLEX version 2.4.2 - more infos here: https://github.com/ogobrecht/plex
-- Performance Hacks by Connor McDonald: https://connor-mcdonald.com/2019/05/17/hacking-together-faster-inserts/
-- For strange line end replacements a big thank to SQL*Plus: https://support.oracle.com/epmos/faces/DocumentDisplay?id=2377701.1 (SQL Failed With ORA-1756 In Sqlplus But Works In SQL Developer)
prompt - insert 847 rows into USERS (exported 2021-01-31 14:24:30.703234000 +00:00)
set define off feedback off sqlblanklines on
alter session set cursor_sharing          = force;
alter session set nls_numeric_characters  = '.,';
alter session set nls_date_format         = 'yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_format    = 'yyyy-mm-dd hh24:mi:ssxff';
alter session set nls_timestamp_tz_format = 'yyyy-mm-dd hh24:mi:ssxff tzr';
begin
insert all
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (1,'Ylcmsajbil','Fojkjryntnixzfh','qvspjgvwmtbi@ghovilkddx.mly')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (2,'Axify','Cofjlkwzxytdih','ajgttnqlds@minokpyfo.gu')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (3,'Ckyqqvuqrkuktb','Igacqwp','qpygabuhbrs@nsjxpgjlle.ze')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (4,'Noythhl','Gausfu','ngmgsbr@duyxqzn.hmyo')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (5,'Kpewbrecnfzsi','Nwbsnjh','xwlhcfaxko@uhqsibdojjp.hsm')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (6,'Qlzyizkl','Gwnaojlvyud','kzndqj@nsosenf.fm')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (7,'Xpepttcemrd','Ktaqqdnqyfvc','uhbnzezvz@buiptt.lkrm')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (8,'Ybyinr','Vngairocujhy','igvfzoegbh@hsepkqiwbst.evs')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (9,'Ctjixltj','Yvsiei','ozpspssyw@vooiyfuf.xeh')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (10,'Lttzwsavnozxu','Kcyjalvzrl','yvwowaqrpku@dyapdumb.fvi')
select * from dual;

/* S N I P */

insert all
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (841,'Gpkabykoveq','Gljhlrijqop','imnhrheyr@ypccyiu.ah')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (842,'Mwrfazphbvmekpw','Kxirzfth','fxoatt@frlbwbn.tf')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (843,'Hzxomvkliaxl','Mstdrrmgfmsy','gpeidglzwfa@hwyumsansy.fet')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (844,'Vwvwezfsd','Xtfouojiymtlu','zgsdtowsvt@ywfngnijgts.ozd')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (845,'Eljntjfkxx','Sifgii','gksggat@ubfmmdopqy.ly')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (846,'Ewvyjeudjb','Anihlpdgeg','gietuk@ezciwejuedy.nuf')
into USERS(U_ID,U_FIRST_NAME,U_LAST_NAME,U_EMAIL) values (847,'Wscdamsgssmouf','Omtaofvlrjs','jrwyzftmbmo@gjylnuez.esq')
select * from dual;
end;
/
commit;
alter session set cursor_sharing = exact;
set define on
```

PLEX speichert die NLS-Einstellungen der aktuellen Session und sorgt dafür, dass die Insert-Skripte mit den gleichen Einstellungen laufen - das bedeutet, dass Ihr keine Fehler bei der Zahlen- oder Datumsumwandlung bekommen solltet. Die Performance-Hacks von Connor sind `alter session set cursor_sharing = force;` und `insert all` - danke für den Hinweis Connor :-)

PLEX hat viele Parameter, um den Export zu konfigurieren - der Fokus von PLEX liegt auf der schnellen Einführung einer Versionskontrolle in bestehenden Projekten (siehe auch [diesen Artikel über PLEX im Allgemeinen](/posts/2018-08-26-plex-plsql-export-utilities/)). Wenn Ihr PLEX nur für den Export von Tabellendaten verwenden wollt, dann solltet Ihr Euch eine Wrapper-Funktion dafür erstellen, die Euren persönlichen Bedürfnissen entspricht - hier ein Beispiel:

```sql
create or replace function to_insert (
  p_table_name  varchar2,
  p_max_rows    integer default 1000,
  p_batch_size  integer default 20
) return clob is
  l_file_collection plex.tab_export_files;
begin
  l_file_collection := plex.backapp(
    p_include_data          => true,
    p_data_max_rows         => p_max_rows,
    p_data_table_name_like  => p_table_name,
    p_data_format           => 'insert:' || to_char(p_batch_size),
    --overwrite defaults to save work for plex:
    p_include_templates     => false,
    p_include_runtime_log   => false,
    p_include_error_log     => false
  );
  return l_file_collection(1).contents;
end;
/
```

Jetzt könnt Ihr jederzeit einen schnellen Export wie folgt durchführen: `select to_insert('USERS', 10000) from dual;`

Viel Spaß beim Exportieren und Skripten :-)

Ottmar
