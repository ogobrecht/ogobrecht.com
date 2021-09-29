---
title: "Ein weiteres Oracle DB Logging-Tool: Console"
description: Einfach zu installieren und funktioniert ohne Kontext und ohne besondere Rechte auf administrative Views
tags: [Open source project, Oracle, APEX, PL/SQL, Log, Debug, Instrumentation]
slug: "ein-weiteres-oracle-db-logging-tool-console"
publishdate: 2021-10-03
lastmod: 2021-10-03 11:00:00
---

{{< figure "Foto von Pete Nuij auf unsplash.com" >}}
![Fliegende Eule](pete-nuij-m-AqW5QCxNQ-unsplash.jpg)
{{< /figure >}}

{{< toc >}}

Es sieht so aus, als wäre es ein Hobby von PL/SQL-Entwicklern ein eigenes Logging-Tool zu entwickeln. Es gibt schon einige freie Tools auf dem Markt und wahrscheinlich viele, die nie veröffentlicht wurden:

- [Logger](https://github.com/OraOpenSource/Logger)
- [PIT](https://github.com/j-sieben/PIT/)
- [Instrumentation for PLSQL](https://github.com/connormcd/instrumentation)
- [Log4plsql](https://github.com/alangibson/log4plsql)
- [ILO](https://sourceforge.net/projects/ilo/)
- [BMC_DEBUG](https://sites.google.com/site/oraplsqlinst/)
- ...

Ein Grund dafür scheint zu sein, dass jeder unterschiedliche Vorstellungen oder Bedürfnisse hat.

## Einfache Installation ohne Kontext und besondere Rechte auf administrative Views

Bei mir ist es so, dass ich ein Logging Tool haben wollte, was sehr einfach zu installieren ist und auch dann funktioniert, wenn man keinen Kontext in der Datenbank anlegen darf und auch keine besonderen Leserechte für administrative Views wie z.B. v$session hat. Man benötigt nur die Rechte zur Erstellung von Tabellen und Packages sowie einem Bereinigungsjob - ziemlicher Standard. Trotzdem ist es möglich, einzelne Nutzer/Sessions für Debugging-Zwecke in einen höheren Log-Level zu versetzen. Da das über den Client-Identifier gelöst ist, funktioniert das auch in einer Umgebung ohne feste Session-ID wie z.B. APEX. Sollte in einer Umgebung kein Client-Identifier gesetzt sein, dann vergibt Console einfach selber einen. Seine Konfiguration liest Console aus einer Tabelle mit nur einer Zeile unterstützt durch den Result-Cache. Das stellt eine resourcenschonende Ausführung sicher. Auch die Prüfung, ob eine Log-Message aufgrund des aktuellen Log-Levels wirklich in die Log-Tabelle geschrieben wird ist hochoptimiert, um in Produktionsumgebungen den Overhead so gering wie möglich zu halten.

## Ein einziges Installtionsskript

Für Console werden alle Skripte in ein einziges Installationsskript zusammengeführt. Da SQLcl auch Skripte aus dem Internet laden kann, könnte man das Tool in einer Minute ohne vorherigen Download auch so installieren: SQLcl aufrufen, im gewünschten Schema anmelden und `@https://raw.githubusercontent.com/ogobrecht/console/main/install/create_console_objects.sql` aufrufen. Ein paar Sekunden später kann man schon loslegen mit dem Logging. Möchte man es in APEX installieren und hat nur einen Browserzugang zu seiner Entwicklungsumgebung, dann ist das einzelne Installtionsskript im SQL Workshop auch sehr hilfreich und Console schnell installiert.

## Produktionssicher ohne weitere Konfiguration

Console loggt per Default nur Fehler (Level 1). Damit ist man auf Produktivsystemen ohne weitere Einstellung auf der sicheren Seite. Möchte man aber auf einem Entwicklungssystem auch andere Level wie Warning (2), Info (3), Debug (4) oder Trace (5) aktivieren und dies nicht für jede Session einzeln tun müssen, dann kann man das global einstellen: `exec console.conf(p_level => 3);`. Mehr dazu im [Getting Started](https://github.com/ogobrecht/console/blob/main/docs/getting-started.md) Dokument.

## Reduzierte Menge Logeinträge durch gespeicherten Call Stack

Console nutzt die Möglichkeiten des Packages `utl_call_stack` um die Anzahl der Logeinträge auf ein mögliches Minimum zu reduzieren. Wer kennt es nicht, das Problem: Im Fehlerfall wird in jeder Unterfunktion ein Logeintrag erstellt, um möglichst viele Details festzuhalten. Am Ende muss man dann zusehen, wie so die Logtabelle zugemüllt wird und man versucht aus den vielen Log-Einträgen herauszufinden, wo denn nun genau der Fehler aufgetreten ist.

Es wäre hilfreich, im Error Backtrace auch die Methodennamen zu sehen - die Datenbank schreibt aber nur die Packagenamen und die Zeilennummer in den Backtrace. Um dieses Problem zu umgehen bietet Console die Möglichkeit anstatt in den Untermethoden einen Fehler in die Log-Tabelle zu schreiben, den Call-Stack mit dem Aufruf `console.error_save_stack` so lange zwischenzuspeichern, bis final in der äußersten Hauptmethode `console.error` aufgerufen wird, was dann den Fehler inklusive gespeichertem Call Stack in die Log-Tabelle einträgt. Zur Verdeutlichung hier ein Skript mit einem Testpackage:

```sql
set define off
set feedback off
set serveroutput on
set linesize 120
set pagesize 40
column call_stack heading "Call Stack" format a120
whenever sqlerror exit sql.sqlcode rollback

prompt TEST ERROR_SAVE_STACK

prompt - compile package spec
create or replace package some_api is
  procedure do_stuff;
end;
/

prompt - compile package body
create or replace package body some_api is
------------------------------------------------------------------------------
    procedure do_stuff is
    --------------------------------------
        procedure sub1 is
        --------------------------------------
            procedure sub2 is
            --------------------------------------
                procedure sub3 is
                begin
                  console.assert(1 = 2, 'Demo');
                exception --sub3
                  when others then
                    console.error_save_stack;
                    raise;
                end;
            --------------------------------------
            begin
              sub3;
            exception --sub2
              when others then
                console.error_save_stack;
                raise;
            end;
        --------------------------------------
        begin
          sub2;
        exception --sub1
          when others then
            console.error_save_stack;
            raise no_data_found;
        end;
    --------------------------------------
    begin
      sub1;
    exception --do_stuff
      when others then
        console.error;
        raise;
    end;
------------------------------------------------------------------------------
end;
/

prompt - call the package
begin
  some_api.do_stuff;
exception
  when others then
    null; --> I know, I know, never do that without a final raise...
          --> But we want only test our logging without killing the script run...
end;
/

prompt - FINISHED, selecting now the call stack from the last log entry...

select call_stack from console_logs order by log_id desc fetch first row only;
```

Hier die Ausgabe des obigen Skriptes - der Abschnitt "Saved Error Stack" ist die Besonderheit von Console, die drei anderen Stack- und Trace-Abschnitte sind die Standards der Datenbank:

```bash
TEST ERROR_SAVE_STACK
- compile package spec
- compile package body
- call the package
- FINISHED, selecting now the call stack from the last log entry...

Call Stack
------------------------------------------------------------------------------------------------------------------------
#### Saved Error Stack

- PLAYGROUND.SOME_API.DO_STUFF.SUB1.SUB2.SUB3, line 14 (line 11, ORA-20777 Assertion failed: Demo)
- PLAYGROUND.SOME_API.DO_STUFF.SUB1.SUB2, line 22 (line 19)
- PLAYGROUND.SOME_API.DO_STUFF.SUB1, line 30 (line 27)
- PLAYGROUND.SOME_API.DO_STUFF, line 38 (line 35, ORA-01403 no data found)

#### Call Stack

- PLAYGROUND.SOME_API.DO_STUFF, line 38
- __anonymous_block, line 2

#### Error Stack

- ORA-01403 no data found
- ORA-06512 at "PLAYGROUND.SOME_API", line 31
- ORA-20777 Assertion failed: Test assertion with line break.
- ORA-06512 at "PLAYGROUND.SOME_API", line 23
- ORA-06512 at "PLAYGROUND.SOME_API", line 15
- ORA-06512 at "PLAYGROUND.CONSOLE", line 750
- ORA-06512 at "PLAYGROUND.SOME_API", line 11
- ORA-06512 at "PLAYGROUND.SOME_API", line 19
- ORA-06512 at "PLAYGROUND.SOME_API", line 27

#### Error Backtrace

- PLAYGROUND.SOME_API, line 31
- PLAYGROUND.SOME_API, line 23
- PLAYGROUND.SOME_API, line 15
- PLAYGROUND.CONSOLE, line 750
- PLAYGROUND.SOME_API, line 11
- PLAYGROUND.SOME_API, line 19
- PLAYGROUND.SOME_API, line 27
- PLAYGROUND.SOME_API, line 35
```

Nutzt man nicht `console.error_save_stack` sondern immer nur `console.error`, dann erhält man im Log wenigstens immer die drei letzten Abschnitte - und das ohne extra Arbeit im Code. Man muss sich dafür nur `console.error` merken.

## Methodennamen angelehnt an JavaScript Console

Ich habe mit Absicht so viele Methodennamen aus der JavaScript Console wiederverwendet wie möglich - damit sollte der Wechsel zwischen Backendcode und Frontendcode nicht so schwer fallen was die Methodennamen angeht. Eine [API-Übersicht](https://github.com/ogobrecht/console/blob/main/docs/api-overview.md) und ein [Getting Started](https://github.com/ogobrecht/console/blob/main/docs/getting-started.md) Dokument helfen bei den ersten Schritten.

## Einfaches loggen von Methodenparametern

Console bietet auch eine einfache Möglichkeit Methodenparameter zu loggen. Hier eine Beispiel-Prozedur mit Parametern aller unterstützten Typen:

```sql
--create demo procedure
create or replace procedure demo_proc (
  p_01 varchar2                       ,
  p_02 number                         ,
  p_03 date                           ,
  p_04 timestamp                      ,
  p_05 timestamp with time zone       ,
  p_06 timestamp with local time zone ,
  p_07 interval year to month         ,
  p_08 interval day to second         ,
  p_09 boolean                        ,
  p_10 clob                           ,
  p_11 xmltype                        )
is
begin
  raise_application_error(-20999, 'Test Error.');
exception
  when others then
    console.add_param('p_01', p_01);
    console.add_param('p_02', p_02);
    console.add_param('p_03', p_03);
    console.add_param('p_04', p_04);
    console.add_param('p_05', p_05);
    console.add_param('p_06', p_06);
    console.add_param('p_07', p_07);
    console.add_param('p_08', p_08);
    console.add_param('p_09', p_09);
    console.add_param('p_10', p_10);
    console.add_param('p_11', p_11);
    console.error('Ooops, something went wrong');
    raise;
end demo_proc;
/
```

In der Ausnahmebehandlung kann man schön erkennen, dass man immer die gleiche Prozedur `console.add_param` aufruft und den Namen und den Wert übergibt. Die Parameter werden in einem Array im Console-Package zwischengespeichert (gekürzt auf maximal 2000 Zeichen) und beim nächsten Aufruf einer Log-Methode (error, warn, info, log, debug oder trace) übernommen. Möchte man nicht, dass die Parameter gekürzt werden, so steht es einem frei den Parameter direkt in die Log-Nachricht zu schreiben - diese ist vom Typ Clob und unterliegt somit keiner Größenbeschränkung.

Hier ein Beispiel-Aufuf der obigen Prozedur:

```sql
begin
  demo_proc (
    p_01 => 'test vc2'                             ,
    p_02 => 1.23                                   ,
    p_03 => sysdate                                ,
    p_04 => systimestamp                           ,
    p_05 => systimestamp                           ,
    p_06 => localtimestamp                         ,
    p_07 => interval '4-2' year to month           ,
    p_08 => interval '7 6:12:42.123' day to second ,
    p_09 => true                                   ,
    p_10 => to_clob('test clob')                   ,
    p_11 => xmltype('<test_xml/>')                 );
end;
/
```

Dieser Aufruf schreibt dann folgende Log-Nachricht - siehe Spalte MESSAGE:

![example log entry](console_logs-single-record.png)

## Markdown-Format für automatisch ermittelte Metadaten

Dem aufmerksamen Leser dürfte nicht entgangen sein, dass die obige Log-Nachricht in Markdown formatiert ist. Wer möchte, kann also seinen Report entsprechend in HTML rendern lassen (z.B. in APEX) - gut lesbar ist es aber auch in Textform. Die Markdown-Tabellenform wie im obigen Beispiel nutzt Console auch für das Loggen weiterer Metadaten wie z.B. APEX-Umgebung, CGI-Umgebung, User-Umgebung und Console-Umgebung. All diese Umgebungen können für jeden einzelnen Log-Aufruf eingeschaltet werden. Sie werden dann an die Log-Nachricht angehängt wie die Parameter. Hier beispielhaft die Signatur der Error-Prozedur:

```sql
procedure error (
  p_message         in clob     default null  , -- The log message itself
  p_permanent       in boolean  default false , -- Should the log entry be permanent (not deleted by purge methods)
  p_call_stack      in boolean  default true  , -- Include call stack
  p_apex_env        in boolean  default false , -- Include APEX environment
  p_cgi_env         in boolean  default false , -- Include CGI environment
  p_console_env     in boolean  default false , -- Include Console environment
  p_user_env        in boolean  default false , -- Include user environment
  p_user_agent      in varchar2 default null  , -- User agent of browser or other client technology
  p_user_scope      in varchar2 default null  , -- Override PL/SQL scope
  p_user_error_code in integer  default null  , -- Override PL/SQL error code
  p_user_call_stack in varchar2 default null    -- Override PL/SQL call stack
);
```

## Erweiterbare Logs durch überladene Log-Methoden

Die Error-Prozedur hat eine Überladung in Form einer Funktion, die die Log-ID zurückliefert. Somit kann man das Logging auch mit eigenen Daten in eigenen Tabellen erweitern z.B. für einen nachgelagerten Freigabeprozess im Falle von spezifischen Fehlern. Dafür ist dann auch der Parameter `p_permanent` gedacht, der dafür sorgt, das der Aufräumjob oder die Prozeduren `console.purge` und `console.purge_all` die entsprechend markierten Log-Einträge nicht löscht und diese permanent zur Verfügung stehen. Alle anderen Log-Methoden (warn, info, log, debug, trace) sind in gleicher Weise und mit den gleichen Parametern implementiert - haben aber teilweise andere Standardwerte. Bei der Error-Methode wird der Call-Stack geschrieben, bei der Trace-Methode  alle Umgebungen.

Die Parameter `p_user_agent`, `p_user_scope`, `p_user_error_code` und `p_user_call_stack` sind dafür gedacht, auch externe Log-Ereignisse erfassen und die automatisch ermittelten Werte der PL/SQL-Umgebung überschreiben zu können. Als Beispiel sei ein externer Ladeprozess in einem Data-Warhouse genannt oder Fehlermeldungen aus dem JavaScript-Frontend einer Anwendung. Mit ein wenig Phantasie werden hier jedem eigene Anwendungsfälle in den Sinn kommen...

## Zeit messen und Dinge zählen

FIXME: fertig schreiben

## Assert, format und andere Helferlein

Selbstverständlich gibt es einige Hilfsmethoden, die das Entwicklerleben angenehmer machen. Zuerst sei die Assert-Prozedur genannt. Dieses immer wiederkehrende Muster sollte jeder kennen:

```sql
if not x < y then
  raise_application_error(-20999, 'x should be less then y');
else
  -- your code here
end if;
```

Besonders hässlich wird es, wenn man mehrere Bedingungen prüfen muss. Das ganze kann man auch als Einzeiler formulieren:

```sql
console.assert(x < y, 'x should be less then x');
```

Möchte man Texte mit dynamischen Informationen anreichern, dann ist man schnell in der Verknüpfungshölle:

```sql
console.assert(
  x < y, 
  'x should be less then y (x='
  || to_char(x)
  || ', y='
  || to_char(y)
  || ')'
);
```

Hier kann einem dann die `format` Funktion helfen:

```sql
console.assert(
  x < y, 
  console.format(
    'X should be less then Y (x=%s, y=%s)',
    to_char(x),
    to_char(y)
  )
);
```

`format` akzeptiert bis zu 10 Parameter und arbeitet nach folgenden Regeln:

1. Ersetze alle Vorkommen von `%0` .. `%9` mit den entsprechenden Parameter `p0` ... `p9`
2. Ersetze `%n` durch neue Zeilen (Zeilenvorschubzeichen)
3. Ersetze alle Vorkommen von `%s` in positioneller Reihenfolge durch die entsprechenden Parameter mit sys.utl_lms.format_message - siehe auch die [Oracle docs](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_LMS.html#GUID-88FFBFB6-FCA4-4951-884B-B0275BD5DF44)

Ich persönlich tippe sehr ungern `dbms_output.put_line`. Console schreibt zwar mit allen Log-Methoden in eine Log-Tabelle, aber eigentlich legt das Wort Console ja nahe, dass wir auch direkt in den Serveroutput schreiben können, oder? Dafür gibt es dann die Prozedur `print`:

```sql
console.print('A message');
```

Dann gibt es noch die Kurzformen von `console.print(console.format(...))` und `console.assert([boolean expression], console.format(...))`:

```sql
console.printf(
  'A %s message with a %n second line of text',
  'dynamic'
);

console.assertf(
  x < y, 
  'x should be less then y (x=%s, y=%s)',
  to_char(x),
  to_char(y)
);
```

Auch häufig gebraucht wird eine schnelle, gecachte Clob-Verknüpfung - da kann dann Console mit [clob_append](https://github.com/ogobrecht/console/blob/main/docs/package-console.md#procedure-clob_append) & [clob_flush_cache](https://github.com/ogobrecht/console/blob/main/docs/package-console.md#procedure-clob_flush_cache) helfen.

Mehr gibt es in der [API-Übersicht](https://github.com/ogobrecht/console/blob/main/docs/api-overview.md).

## APEX Error Handling Function

Für APEX bringt Console eine sogenannte "Error Handling Function" mit, die Fehler innerhalb der APEX-Laufzeitumgebung in die Log-Tabelle eintragen kann. Wer das nutzen möchte, muss diese Funktion in seiner Anwendung im "Application Builder" unter "Edit Application Properties > Error Handling > Error Handling Function" eintragen: `console.apex_error_handling`.

{{< figure "APEX Error Handling mit eingeschalteter ASCII Art" >}}
![APEX Error Handling mit eingeschalteter ASCII Art](apex-error-handling-function.png)
{{< /figure >}}

## APEX Plug-In für die Erfassung von Frontend-Fehlern

Desweiteren gibt es noch ein APEX Dynamic Action Plug-In, welches JavaScript-Fehler im Browser der Anwender per AJAX-Call in die Log-Tabelle einträgt. Damit bekommt man auch mit, wenn es im Frontend bei den Anwendern nicht so richtig rund läuft...

Wer es nutzen möchte findet es im Ordner `install/apex_plugin.sql`.

## Inspirationsquellen

Ich bin nicht allein auf der Welt und ohne die Anderen geht auch bei der Softwareentwicklung nicht viel. Hier ein paar Links zu Seiten oder Projekten, die mich auf dem Weg zu einem eigenen Logging-Tool inspiriert haben:

- [JavaScript Console API](https://developers.google.com/web/tools/chrome-devtools/console/api)
- [Logger](https://github.com/OraOpenSource/Logger)
- [Instrumentation for PLSQL](https://github.com/connormcd/instrumentation)
- [PIT](https://github.com/j-sieben/PIT/)
- [Oracle Magazine - Sophisticated Call Stack Analysis](https://blogs.oracle.com/oraclemagazine/post/sophisticated-call-stack-analysis)

Ein besonderer Dank geht an [Dietmar Aust](https://twitter.com/daust_de), der mir in einer frühen Phase Zeit und Ideen mit einer Diskussionssitzung geschenkt hat.

## Projekt-Homepage

Console ist auf [GitHub](https://github.com/ogobrecht/console) gehostet.

Viel Spaß beim Loggen und Fehler suchen :-)

Ottmar
