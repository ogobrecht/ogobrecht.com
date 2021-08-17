---
title: "Yet Another Logging Tool: Console"
description: Easy installation and a remedy for cluttered error logs
tags: [project, oracle, logging, debugging]
publishdate: 2030-01-01
lastmod: 2030-12-31 14:00:00
---

It looks like it is a hobby of PL/SQL developers to develop their own logging
tool...

There are already some free tools on the market and probably many that have
never been published:

- [Logger](https://github.com/OraOpenSource/Logger)
- [PIT](https://github.com/j-sieben/PIT/)
- [Instrumentation for PLSQL](https://github.com/connormcd/instrumentation)
- [Log4plsql](https://github.com/alangibson/log4plsql)
- [ILO](https://sourceforge.net/projects/ilo/)
- [BMC_DEBUG](https://sites.google.com/site/oraplsqlinst/)
- ...

One reason seems to be that everyone has different ideas or needs. For me, I
wanted a logging tool that is very easy to install and works even if you are not
allowed to create a context in the database. You only need the rights to create
tables and packages and a cleanup job - pretty standard. A context is optional
and will be used automatically if present.

Speaking of easy installation - since for Console all scripts are merged into a
single installation script and SQLcl can also load scripts from the Internet,
you could install the tool in a minute without downloading it first: Call SQLcl,
log into the desired schema and call
`@https://raw.githubusercontent.com/ogobrecht/console/main/install/create_console_objects.sql`.
A few seconds later you can start logging or instrumenting. If you want to
install it in APEX and have only browser access to your development environment,
the single install script in SQL Workshop is also very helpful and Console
installs quickly.

A note for those in a hurry: Console logs only errors (level 1) by default. This
means that you are on the safe side on production systems without any further
settings. But if you want to enable other levels like warning (2), info (3),
debug (4) or trace (5) on a development system and don't want to do this for
each session individually, you can set it globally: `exec
console.conf_level(3);`. More about this in the [Getting
Started](https://github.com/ogobrecht/console/blob/main/docs/getting-started.md)
document.

Besides that I wanted to use the new possibilities of the package
`utl_call_stack` to reduce the number of log entries to a possible minimum. Who
doesn't know the problem: In case of an error, a log entry is created in each
subfunction to record as many details as possible. In the end you have to watch
how the log table gets cluttered and you try to find out from the many log
entries where exactly the error occurred.

It would be helpful to see the method names in the error backtrace - but the
database only writes the package names and the line number in the backtrace. To
work around this problem Console offers the possibility instead of writing an
error in the submethods into the log table, to save the call stack with the call
`console.error_save_stack` until finally in the outermost main method
`console.error` is called, which then enters the error including saved call
stack into the log table. For clarification, here is a script with a test
package:

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

Here is the output of the above script - the Saved Error Stack section is
Console's special feature, the other three stack and trace sections are the
database's standards:

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

If you don't use `console.error_save_stack` but always `console.error`, then you
get at least the last three sections in the log - and without extra work in the
code. You only have to remember `console.error`.

By the way, remember - I intentionally reused as many method names from the
JavaScript Console as possible - so switching between backend code and frontend
code shouldn't be that hard as far as method names are concerned. An [API
Overview](https://github.com/ogobrecht/console/blob/main/docs/api-overview.md)
and a [Getting
Started](https://github.com/ogobrecht/console/blob/main/docs/getting-started.md)
document help with the first steps.

It remains to mention that Console for APEX comes with a so called "Error
Handling Function" that can log errors within the APEX runtime environment. If
you want to use this, you have to enter this function in your application in the
"Application Builder" under "Edit Application Properties > Error Handling >
Error Handling Function": `console.apex_error_handling`.

Furthermore, there is a Dynamic Action Plug-In, which enters JavaScript errors
in the user's browser via AJAX call into the log table. This way you also get to
know if the frontend is not running smoothly...

Console is hosted on [GitHub](https://github.com/ogobrecht/console).

Happy logging and debugging...

Ottmar
