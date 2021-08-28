---
title: Quick start - version control for existing Oracle projects
description: DOAG Red Stack Magazin 03-2019
tags: [Oracle, APEX, Version control, DOAG]
slug: quick-start-version-control-for-oracle-projects
publishdate: 2019-07-20
lastmod: 2019-08-15 21:00:00
---

*Many Oracle projects still do not use version control. The reasons for this are manifold. Mostly it is assumed that the database is a safe place for the source code. With a working backup this is also correct, but in any case one loses the complete history of changes. Often in running projects there is not enough time to deal with the introduction of source code versioning, because at first sight there is no direct benefit to be seen. Who dares to take a second look under time pressure? This article wants to lower the hurdle for the introduction of a version management a little bit.*

{{< toc "Inhaltsverzeichnis" >}}

## Note DOAG

This article appeared in DOAG Red Stack magazine 03-2019 and is also available in the [original][doag]. Unlike the original, updates may occur here on my blog if relevant things change. For example, since version two of the mentioned PLEX (PL/SQL Export Utilities) project, an APEX installation is no longer a requirement. This means that also pure Oracle database projects can use PLEX - read more in [this blog entry][plex2].

[doag]: https://www.doag.org/formes/pubfiles/11388332/03_2019-Red_Stack_Magazin-Ottmar_Gobrecht-Schnellstart_Versionskontrolle_fur_existierende_Oracle_(APEX)Projects.pdf
[plex2]: /posts/2019-06-26-new-major-version-of-plex-available/

## Introduction

The first step is the most important one, as everyone knows who has ever finally set out after much hesitation - whatever it was about. The same is true for source code versioning. Once you're on your way, you wonder how you got along for so long without it. A versioned source code base increases your comfort zone during development, and the time invested pays off several times over. But how do you take the first step as easily and quickly as possible? How to design the structure of a repository?

## Workflow change: file-based working

One of the most important questions is: Can I continue to work as before? The answer depends entirely on how one has worked so far. Basically, working with a source code versioning also means a change away from developing in the database. Changing and compiling code directly in the database or changing tables with the tool of one's choice must evolve to file-based work. This means working with a file in the local source code repository with the tool of choice. The changes are then compiled from the file. For schema changes, scripts must contain the necessary DDL code. Depending on the tools used so far, this is rather a subtle difference when editing logic, but a big difference when changing database objects like tables. If a schema diff tool was previously used to transport changes from the development environment into production, then this might even look like a step backwards at first glance.

The point here is that you can only get a usable source code history if you are consistent about working file-based. There can also be an intermediate step towards this approach. One continues to work as before and regularly exports all objects of the schema to the source code management. This way one gets at least a certain ordered transparency of the changes. If then in the course of the project the advantages of this procedure become apparent, one usually still lacks the information, who executed the respective changes. In addition, the transparency gained quickly awakens desires such as "If I have the old code in the repository, then I may try something, I can go back if necessary". The first hurdle is already taken and the openness to perhaps really get started is there.

That something like this can work even better is something that most developers come up with themselves. For example, creating a branch (development branch) in the local repository. This way you can try something out without running the risk of having to discard your changes due to an unexpected bug. You can easily switch to the main (parallel) branch, work on the bugfix, update your branch to the changed main branch and then just keep trying. All this without the danger of losing things or influencing other colleagues. Have I lost anyone now? No problem, just get started - only practice helps here.

## Tool comparison: DDL export

How do you accomplish the first step? How do you export the schema objects of your application into a well sorted directory structure? Most of the used graphical development tools provide an export function for this purpose. Depending on the tool, this is more or less suitable for building a source code repository. Therefore, let's take a look at how the most commonly used tools SQL Developer, PL/SQL Developer and Toad can do this. A word beforehand: the intention of the schema export of these tools is actually to bring the objects into another schema, maybe even into another database, and not to create a source code repository. The following questions move us when it comes to building one:

- Is one script file per object possible?
- Are subdirectories per object type possible?
- Are separate files for foreign keys possible? (Useful for simpler master scripts)
- Can "Object already exist" errors be prevented? (Or in other words: are the scripts restartable?)
- Can data be exported? (If possible in CSV format for tracking master data changes).
- Is it possible to export an APEX app? (Possibly also broken down into the individual parts such as pages, shared components, etc.)

Figure 1 shows the result related to the question.

{{< figure "Figure 1: Tool comparison DDL export" >}}
| Criterion              | SQL Dev.      | PL/SQL Dev.    | Toad         |
|------------------------|---------------|----------------|--------------|
| File per object        | Yes           | Yes            | Yes          |
| Subdir. per type       | Yes           | No             | Yes          |
| FK constr. separate    | Yes           | No             | Yes          |
| Prevent "object exist" | No            | No             | No           |
| Export data            | Yes           | No             | ***partly*** |
| Export APEX app        | ***partly***  | No             | No           |
{{< /figure >}}

Notes on SQL Developer:

- Is the clearest
- Many formats for data export (also CSV)
- Extensively configurable
- Export APEX App only with Commandline version SQLcl

Notes on PL/SQL Developer:

- Little configurable
- Disappointing for building a source code repository

Notes on Toad:

- Two export options (at least).
  - Either subdirectories per object type....
  - ... or data
- Data only as insert statements
- Extensively configurable, relatively unclear

None of the tools provides us with a ready-made, well-structured source code repository. You have to do more or less a lot of rework. That doesn't mean it can't be done, especially since sorting the objects into a reasonable structure should be a one-time job. Only in the case of exporting the APEX application one would like to have an automatic solution, because this export will have to be done more often in the future. This is in the nature of APEX as a declarative "low code framework".

We develop the APEX application in the browser and the meta-data of the application resides in the APEX repository of the database. An export of the application can also be done with the browser, but in doing so you will only get a single large SQL file with the entire application. Desirable for a source code repository would be an export of the individual parts such as pages, shared components, plugins, etc.. This would then make it possible for the application to track how it has developed and also a search in the repository for e.g. a specific package call makes much more sense with a disassembled APEX application. In the past, you could use the APEX export splitter for this, basically a Java class that comes with every APEX version to this day. The disadvantage is that you have to take the directory structure as created by the splitter or you change it afterwards with local scripts on your PC. However, it would be nicer to be able to adjust the directory structure already during the export in order to be able to store all master scripts in a central folder of the repository.

Since APEX version 5.1.4 there is the APEX_EXPORT package for this purpose. With this package you can export either the whole script or the splitted version. The return format in both cases is a collection - each line of the collection contains a path specification for the respective export file and a CLOB field with the content. So you could edit this collection in an export script and adapt the path specifications to your own needs. This is exactly what the tool package PLEX, published as open source by the author of this article, does - the name stands for <span style="color:red;">PL</span>/SQL <span style="color:red;">Ex</span>port Utilities. Furthermore, PLEX can answer yes to any of the above questions about DDL export - no wonder, it was designed for that.

## Quickstart: Package PLEX

PLEX aims to be able to select the first version of the repository as a BLOB with a simple query. After saving the BLOB to the local directory system on the PC with the extension .zip you can unpack it and find in the generated directory structure script examples for future semi- or fully automatic exports and deployments via shell command or SQL*Plus. A possible first export could look like shown in Listing 1.

{{< figure "Listing 1: Possible first export" >}}
```sql
WITH
  FUNCTION backapp RETURN BLOB IS
  BEGIN
    RETURN plex.to_zip(plex.backapp(
      p_app_id               => 100,
        /* If null, we simply skip the APEX app export. 
        Parameter only available if APEX installed. */
      p_include_object_ddl   => true,
        /* If true, include DDL of current user/schema and 
        all its objects. */
      p_include_templates    => true,
        /* If true, include templates for README.md, export 
        and install scripts. */
      p_include_runtime_log  => true,
        /* If true, generate file plex_backapp_log.md with 
        runtime statistics. */
      p_include_data         => true,
        /* If true, include CSV data of each table. */
      p_data_max_rows        => 1000,
        /* Maximum number of rows per table. */
      p_data_table_name_like => 'DEMO_PRODUCT_INFO,DEMO_STATES' 
        /* A comma separated list of like expressions to filter 
        the tables. Example: 'EMP%,DEPT%' will be translated to 
        "where ... and (table_name like 'EMP%' escape '\' or
        table_name like 'DEPT%' escape '\')". */
    ));
  END backapp;

SELECT backapp FROM dual;
```
{{< /figure >}}

Since PLEX has boolean parameters, we use an inline function in the with clause. If you use a database version smaller than 12c, you can create an auxiliary function similar to the example. PLEX has some more parameters to configure e.g. the APEX App Export. More details can be found on the official project page at [github.com/ogobrecht/plex](https://github.com/ogobrecht/plex). Depending on the size of the schema and the APEX app, this initial call can take anywhere from a few seconds to several minutes. This is because in the background for each object the package DBMS_METADATA is used to generate the DDL of the object. If you are interested in runtime information, you will find a log file in the main directory of the export with information about what PLEX did and how long the respective steps took. PLEX itself now exists in a first version - suggestions for improvements or bug reports are welcome and can be reported as issues on the project page.

From here on it strongly depends on the needs of the respective project if and how often you run a DDL export. The normal way should be a regular export of the APEX application. Everything else should be processed locally from now on and as a result there should be no need for an export. However, as mentioned at the beginning, there may be situations where you regularly export all schema objects in order to document the application. However, this should only be seen as an intermediate step towards a file-based way of working. 

Generated code is a special case: So for example using Quick-SQL in APEX or generating table APIs. Here one can consider exporting the generated code with appropriately configured object filters. For APIs you should consider versioning the generator instead of the generated code - but this depends entirely on whether the generated code is still being manually modified or not. Any manually generated code should be versioned.

## Geschwindigkeit: Immer Skripte

As you can already see from the script examples provided by PLEX, the goal should be to execute any deployment by script. This also includes the consideration to export the object DDL only at the very first time - because what happens e.g. when exporting table DDL? If you have written another column into the table script via Alter Table statement and made sure that it is restartable (see Listing 2), then another DDL export overwrites the Alter statement and our table script simply contains the new column listed in the Create Table statement. However, this is never executed again due to the restartability, since our table already exists.

{{< figure "Listing 2: Restartable script" >}}
```sql
BEGIN
  FOR i IN (
    SELECT 'DEMO_STATES' AS object_name
      FROM dual 
     MINUS
    SELECT object_name 
      FROM user_objects
  ) LOOP
    EXECUTE IMMEDIATE q'[
----------------------------------------
CREATE TABLE "DEMO_STATES" (
  "ST"         VARCHAR2(30), 
  "STATE_NAME" VARCHAR2(30)
) 
----------------------------------------
    ]';
  END LOOP;
END;
/

BEGIN
  FOR i IN (
    SELECT 'STATE_DESCRIPTION' AS column_name 
      FROM dual 
     MINUS
    SELECT column_name 
      FROM user_tab_columns
     WHERE table_name  = 'DEMO_STATES'
       AND column_name = 'STATE_DESCRIPTION'
  ) LOOP
    EXECUTE IMMEDIATE q'[
----------------------------------------
ALTER TABLE demo_states ADD (
  state_description VARCHAR2(255)
)
----------------------------------------
    ]';
  END LOOP;
END;
/
```
{{< /figure >}}

Thus, we now have a source code file that is no longer suitable for deployment. A pity actually, because until just now we could have simply called all object scripts with our master script and only the changes (like our new column) would really have been executed - a simple deployment and a clear history in the repository. This is contrasted with the automatic creation of diff scripts, which are sometimes not restartable and risk data loss even with slightly more complicated schema changes. One cannot avoid checking the generated scripts for correctness and making manual adjustments for any data migrations, even with very expensive tools of this class. No one takes the decision of which way to go away from you. Now we are in the middle of the discussion on how to deploy to the target system. PLEX can't help here either - except that the package per se tries to extract all necessary object DDLs in a way that they can be restarted. Here we are in the wide field of individual needs of a project. The script examples supplied by PLEX must be adapted to the needs of the respective project in any case. For example, the author almost always distinguishes between scripts for the backend and the frontend - both for export and deployment.

## Consideration: Directory structure in the repository

How should you structure your repository? Here is a suggestion that has proven to be beneficial for me personally over time. Every project may have different ideas. I use a simple listing here - the first words of each list item represent the directory name, and any explanations are in parentheses after it:

- app_backend (our schema DDL)
  - constraints (one folder per object type)
  - package_bodies
  - packages
  - ref_constraints
  - sequences
  - tables
  - ...
- app_data (tracking of master data, optional)
- app_frontend (our APEX app)
  - pages
  - shared_components
  - ...
- docs (the documentation)
- reports
- scripts (all master scripts combined)
  - logs (export and installation logs)
    - export_app_100_from_MYSCHEMA_at_DEV_20190315_132542
    - install_app_100_into_MYSCHEMA_at_TEST_20190318_083756
    - ...
  - misc (frequently used scripts like recompile schema)
  - 1_export_app_from_DEV.bat (shell script with parameters for the actual SQL export script)
  - 2_install_app_into_TEST.bat (Shell script with parameters for the SQL deployment script)
  - 3_install_app_into_PROD.bat (shell script with parameters for the custom SQL deployment script)
  - export_app_custom_code.sql (export master script with customizations)
  - install_app_custom_code.sql (Deployment Master Script with individual customizations per release)
  - install_backend_generated_by_plex.sql (called from master script)
  - install_frontend_generated_by_apex.sql (called by the master script)
- tests (unit and frontend tests)
- README.md (general information about the project and links to the documentation)

The repository should be logically structured and not contain extremely deep directory structures to make it easier to use. All master scripts are united in one script folder, also the installation script generated by APEX for the frontend. All master scripts should store their respective feedback in corresponding log files in the logs subfolder during use - this makes exports of source code and deployments to target systems traceable.

## Outlook: CI/CD & Schema Migration

The outlined discussion of deployment already hints at it: Simply setting up a source code repository and you're done is not the solution. That was just the first step to warm up. Once you have structured everything and made it executable via script, you can automate the deployment in the second step. The content of this discussion is far beyond the scope of this article, which focuses on the first step. Therefore, the author suggests everyone not to stop after this first step and to consider further steps. Martin Fowler, for example, has written a very good basic article on the subject - he considers every change to the database as a migration. For further study, the following entry points should therefore be mentioned:

- Antti Kirmanen: [Git vs. Subversion (SVN): Welches Versionskontrollsystem sollten Sie nutzen?](https://entwickler.de/online/development/git-subversion-svn-versionskontrollsystem-579792227.html)
- Martin Fowler: [Evolutionary Database Design](https://www.martinfowler.com/articles/evodb.html)
- Samuel Nitsche: 
  - [There is no clean (database) development without Version Control](https://cleandatabase.wordpress.com/2017/09/22/there-is-no-clean-database-development-without-version-control/)
  - [“One does not simply update a database” – migration based database development](https://cleandatabase.wordpress.com/2017/11/28/one-does-not-simply-update-a-database-migration-based-database-development/)
- Blain Carter: 
  - [Tips to help PL/SQL developers get started with CI/CD](https://learncodeshare.net/2018/04/30/tips-to-help-pl-sql-developers-get-started-with-ci-cd/)
  - [CI/CD for Database Developers – Export Database Objects into Version Control](https://learncodeshare.net/2018/07/16/ci-cd-for-database-developers-export-database-objects-into-version-control/)
- Jeff Smith: [19.X SQLcl Teaser: LIQUIBASE](https://www.thatjeffsmith.com/archive/2019/01/19-x-sqlcl-teaser-liquibase/)

Happy version controlling :-)

Ottmar
