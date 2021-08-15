---
title: Yet another error logging tool
description: Easy installation and a remedy for cluttered error logs
tags: [oracle, script]
lang: en
publishdate: 2030-01-01
lastmod: 2030-12-31 14:00:00
---

Es sieht so aus, als wäre es ein Hobby von PL/SQL-Entwicklern ein eigenes
Open-Source-Logging-Tool zu entwickeln...

Es gibt schon einige auf dem Markt (die letzten drei scheinen nicht mehr aktiv
gepflegt zu werden):

- [Logger](https://github.com/OraOpenSource/Logger)
- [PIT](https://github.com/j-sieben/PIT/)
- [Instrumentation for PLSQL](https://github.com/connormcd/instrumentation)
- [Log4plsql](https://github.com/alangibson/log4plsql)
- [ILO](https://sourceforge.net/projects/ilo/)
- [BMC_DEBUG](https://sites.google.com/site/oraplsqlinst/)

Ein Grund dafür scheint zu sein, dass jeder unterschiedlich Vorstellungen oder
Bedürfnisse hat. Bei mir ist es so, dass ich ein Logging Tool haben wollte, was
sehr einfach zu installieren ist und auch funktioniert, wenn man keinen Kontext
in der Datenbank anlegen darf. Man benötigt nur die Rechte zur Erstellung von
Tabellen und Packages sowie einem Bereinigungsjob - ziemlicher Standard. Ein
Kontext ist optional und wird bei Vorhandensein automatisch genutzt. Apropo
einfache Installtion - da ich alle Skripte in ein einziges Installationskript
zusammenführe und SQLcl auch Skripte aus dem Internet laden kann, könnte man
mein Logging-Tool in einer Minute ohne vorherigen Download auch so installieren:
SQLcl aufrufen, im gewünschten Schema anmelden und
`@https://raw.githubusercontent.com/ogobrecht/console/main/install/create_console_objects.sql`
aufrufen. Ein paar Sekunden später kann man schon loslegen mit dem Logging bzw.
der Instrumentierung.

Daneben wollte ich die neuen Möglichkeiten des Packages utl_call_stack benutzen
um die Anzahl der Logeinträge auf ein mögliches Minimum zu reduzieren. Wer kennt
es nicht, das Problem: Im Fehlerfall wird in jeder Unterfunktion ein Logeintrag
erstellt, um möglichst viele Details festzuhalten. Am Ende muss man dann
zusehen, wie so die Logtabelle zugemüllt wird und man versucht aus den vielen
Log-Einträgen herauszufinden, wo denn nun genau der Fehler aufgetreten ist. Es
wäre hilfreich, im Error Backtrace auch die Methodennamen zu sehen - die
Datenbank schreibt aber nur die Package-Namen und die Zeilennummer in den
Backtrace. Um dieses Problem zu umgehen bietet mein Logging-Tool die Möglichkeit
anstatt in den Untermethoden einen Fehler in die Log-Tabelle zu schreiben, den
Call-Stack mit dem Aufruf `console.error_save_stack` so lange
zwischenzuspeichern, bis final in der Hauptmethode `console.error` aufgerufen
wird, was dann den Fehler inklusive gespeichertem Call Stack in die Log-Tabelle
einträgt. Zur Verdeutlichung hier ein Testpackage:

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
{{/}}

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

Hier die Ausgabe des obigen Skriptes - der Abschnitt "Saved Error Stack" ist die
Besonderheit meiner Implementierung, die drei anderen Stack- und
Trace-Abschnitte sind die Standards der Datenbank:

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

Nutzt man nicht `console.error_save_stack` sondern immer nur `console.error`,
dann erhält man im Log wenigstens immer die drei letzten Abschnitte - und das
ohne extra Arbeit im Code. Man muss sich dafür nur `console.error` merken.
Übrigens merken - ich habe mit Absicht so viele Methodennamen aus der JavaScript
Console wiederverwendet wie möglich - damit sollte der Wechsel zwischen
Backendcode und Frontendcode nicht so schwer fallen was die Methodennamen
angeht.

...
