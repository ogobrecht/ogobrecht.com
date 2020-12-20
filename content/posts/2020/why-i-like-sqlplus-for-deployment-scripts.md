---
title: Why I Like SQL*Plus for Deployment Scripts
description: SQLcl is eating my error messages
tags: [oracle, script, sqlplus]
lang: en
publishdate: 2020-01-02
lastmod: 2020-01-03 19:40:00
aliases: [/posts/2020-01-02-why_i_like_sqlplus_for_deployment_scripts/]
---

The following simplified example deployment master script is given:

```sql
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
spool deployment.log

prompt
prompt Example Deployment Master Script
prompt ========================================

prompt Step 1: Dummy for demonstration
-- normally we call here some other scripts like
-- @other-script.sql

prompt Step 2: Error test in anonymous block
begin
  raise_application_error(-20000, 'Error test for SQL*Plus <> SQLcl comparison');
end;
/

prompt ========================================
prompt Deployment Done :-)
prompt

spool off
```

When we call this in SQL*Plus (version 19.5), we get the following output (in the console and also in deployment.log) with an indication of what went wrong with our deployment:

```
Example Deployment Master Script
========================================
Step 1: Dummy for demonstration
Step 2: Error test in anonymous block
begin
*
ERROR at line 1:
ORA-20000: Error test for SQL*Plus <> SQLcl comparison 
ORA-06512: at line 2 
```

Ok, this error message is stupid, but usually, I get some useful information here to fix my problem in the deployment script - especially when the problematic script is a bit longer...

When we call this in SQLcl (latest version 19.4 on Windows) we get the following output (in the console and also the deployment.log):

```
Example Deployment Master Script
========================================
Step 1: Dummy for demonstration
Step 2: Error test in anonymous block
```

Mhhh... What was going on here? Why was my script terminating in step 2?

That's one reason why I like SQL\*Plus a bit more than SQLcl for deployment scripts. The fast start time of SQL\*Plus is another reason. Nevertheless, SQLcl is a cool command-line tool.

Happy scripting :-)<br>
Ottmar

P.S.: There is a small [Twitter discussion][twitter] around this...

## UPDATE January 3, 2020

[Jeff Smith has confirmed that this bug was fixed in SQLcl version 19.4][jeff]. I was using 19.4 - but on Windows. It turns out that the bug is still there - only on Windows, not Mac, not Linux...

So, if you are facing this problem on Windows then you have to wait for a future release or set as a workaround the feedback on:

```sql
set define off verify off feedback on
<snip>
```

Here the output on my Windows 10 laptop:

```
Demo Deployment Master Script
========================================
Step 1: Dummy for demonstration
Step 2: Begin error test in anonymous block
Rollback

Error starting at line : 10 File @ C:\temp\deployment.sql
In Command -
begin
  raise_application_error(-20000, 'error test for SQL*Plus <> SQLcl comparison');
end;
Error report -
ORA-20000: error test for SQL*Plus <> SQLcl comparison
ORA-06512: at line 2
20000. 00000 -  "%s"
*Cause:    The stored procedure 'raise_application_error'
           was called which causes this error to be generated.
*Action:   Correct the problem as described in the error message or contact
           the application administrator or DBA for more information.
```

If you are on Mac OS or Linux then you have to update to the latest SQLcl version 19.4 or use also the described workaround.

## UPDATE July 20, 2020

The bug still exists in SQLcl 20.2 and SQL Developer 20.2 under Windows - we have to wait a bit longer...

Again: happy scripting :-)<br>
Ottmar

[post]: /posts/2020-01-01-download_blobs_with_sqlplus
[twitter]: https://twitter.com/ogobrecht/status/1212646721127366656
[jeff]: https://twitter.com/thatjeffsmith/status/1213102639497515009
