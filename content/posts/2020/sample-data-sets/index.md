---
title: Sample Data Sets for Oracle
description: A collection of common data sets for testing purposes
tags: [project, oracle, script]
slug: sample-data-sets-for-oracle
publishdate: 2020-05-25
lastmod: 2020-05-25 14:00:00
---

Sometimes you need only some small tables and some rows of data to play around with, to test things out. I think most of you immediately would say EMP, DEPT...

Sure, but a bit more data would be nice. Ok, OE and HR schema...

Sure, but I have no SYS rights on the database in my current project to install the schemas, can I have it in my current dev schema?...

Sure, but then I have to fiddle a bit with the scripts to make it run in my dev schema, I need it fast, no time at all...

Mmhhh, sounds this familiar to you? Maybe I can help...

The sample data sets from Oracle were normally created for a dedicated schema. I changed that and omitted all the schema creation parts of the scripts. Instead, all objects from a data set get a prefix - an example: All objects from the customer orders schema (one of the newer data sets from Oracle) are prefixed with CO_. This allows me to use all data sets in parallel in a single schema and easily identify the data set the object belongs to.

All table scripts are created with identity columns and the simplest possible options for easy readability - no fancy constraint and index names. Constraints and indexes will be renamed with global helper scripts after the table creation. Only real indexes are coded - foreign key indexes are generated with a global helper script too.

For each data set, you have always the same three scripts to handle the installation/data refresh/uninstallation.

## List of Data Sets, Copyrights

- EMP & DEPT (2 tabs, 18 rows), [source](https://github.com/oracle/dotnet-db-samples/blob/master/schemas/scott.sql), Copyright Oracle ([MIT license](https://github.com/oracle/dotnet-db-samples/blob/master/LICENSE))
- Order Entry & Human Resources (15 tabs, 3.002 rows), [source oe](https://github.com/oracle/db-sample-schemas/tree/master/order_entry), [source hr](https://github.com/oracle/db-sample-schemas/tree/master/human_resources), Copyright Oracle ([MIT license](https://github.com/oracle/db-sample-schemas/blob/master/LICENSE.md))
- Customer Orders (5 tabs, 6.325 rows), [source](https://github.com/oracle/db-sample-schemas/tree/master/customer_orders), Copyright Oracle ([MIT license](https://github.com/oracle/db-sample-schemas/blob/master/LICENSE.md))
- Sakila DVD Rental Store (16 tabs, 46.273 rows), [source](https://github.com/jOOQ/jOOQ/tree/master/jOOQ-examples/Sakila), [original source](https://code.google.com/archive/p/sakila-sample-database-ports/), Copyright MySQL AB documentation team, DB Software Laboratory, Lukas Eder ([BSD-3-Clause license](http://opensource.org/licenses/BSD-3-Clause))

For more info about the Oracle sample schemas see the [docs](https://docs.oracle.com/database/121/COMSC/overview.htm#COMSC002).

## List of Global Helper Scripts

- Disable/enable all foreign key constraints
- Create missing foreign key indexes
- Unify constraint names
- Unify index names
- Sync sequence values to data

You can find the project on [GitHub](https://github.com/ogobrecht/sample-data-sets-for-oracle).

Hope this helps someone else...

Happy data modeling and testing<br>
Ottmar

P.S. For those of you who are working with Oracle APEX: Have a look under SQL Workshop > Utilities > Sample Datasets
