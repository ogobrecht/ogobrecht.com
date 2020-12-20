---
title: PLEX - PL/SQL Export Utilities
description: Export Oracle APEX app, ORDS modules, all schema objects and table data in one go
tags: [project, oracle, apex, plsql, version-control]
lang: en
publishdate: 2018-08-26
lastmod: 2020-01-01 20:15:00
---

> UPDATE 2019-06-26 regarding PLEX v2.0.0: PLEX can now be installed and used without an APEX installation. However, to export an APEX app you need APEX 5.1.4 or higher installed on your system. Without APEX your PLEX package has no options for an app export because of conditional compilation. You are still able to export your schema DDL and table data. Hope this helps some folks out there -- Ottmar

PLEX is a standalone PL/SQL package with export utilities. It was created to be able to quickstart version control for existing (APEX) apps. It currently has two main functions called __BackApp__ and __Queries_to_CSV__. Queries_to_CSV is used by BackApp as a helper function, but its functionality is also useful as a standalone. This post is all about BackApp, which has the following features:

- Export the app definition of an APEX app (splitted files and optional single SQL file)
- Export all ORDS modules from the current schema
- Export all object DDL from the current schema
- Export table data into CSV files
- Provide basic script templates for export/import of whole app for DEV, TEST and PROD 
- Everything in a (hopefully) nice directory structure ready to use with version control
- Return value is a file collection of type plex.tab_export_files (it was apex_t_export_files before PLEX version 2) for further processing
  - Each file in the collection is represented by a record with two columns
    - `name` of type VARCHAR2(255), which is in fact the file path
    - `contents` of type CLOB
  - You can optionally zip the file collection with the helper function `to_zip`
  - Also see the my previous post on [how to handle the apex_t_export_files type returned by the APEX_EXPORT package with SQL*Plus][prev_post]



Getting Started
----------------

1. [Download the latest code][plex_download]
1. Run the provided install script `plex_install.sql` (provides compiler flags) in your desired schema - could also be a central tools schema, don't forget `grant execute on plex to xxx`
1. Startup your favorite SQL Tool, connect to your app schema and fire up the following query:

```sql
select plex.to_zip(plex.backapp(p_app_id => yourAppId)) from dual;
```

Save the resulting BLOB file under a name with the extension `.zip` and extract it to a local directory of your choice. You will find this directory structure and files:

```txt
- app_backend (only, when p_include_object_ddl is set to true, see next example)
  - package_bodies
  - packages
  - tables
  - ref_constraints
  - ...
- app_data (only, when p_include_data is set to true)
- app_frontend (for the apex app files without subfolder fxxx)
  - pages
  - shared_components
  - ...
- app_web_services (only, when p_include_ords_modules is set to true)
- docs
- scripts
  - logs
  - templates
    - 1_export_app_from_DEV.bat
    - 2_install_app_into_TEST.bat
    - 3_install_app_into_PROD.bat
    - export_app_custom_code.sql
    - install_app_custom_code.sql
  - install_backend_generated_by_plex.sql
  - install_frontend_generated_by_apex.sql
  - install_web_services_generated_by_ords.sql
- tests
- plex_README.md
- plex_runtime_log.md
```

If you like, you can fully configure your first export into the zip file. The `PLEX.BackApp` method has boolean parameters, so you need to use an inline function in a pure SQL context. You can also use an anonymous PL/SQL block or you create a small SQL wrapper for the method like the inline function of the example. All parameters are optional and listed here with their default values:

```sql
-- Inline function because of boolean parameters (needs Oracle 12c or higher).
-- Alternative create a helper function and call that in a SQL context.
WITH
  FUNCTION backapp RETURN BLOB IS
  BEGIN
    RETURN plex.to_zip(plex.backapp(
      -- All parameters are optional and shown with their defaults
      -- APEX App (only available, when APEX is installed):
      p_app_id                      => null,  -- If null, we simply skip the APEX app export.
      p_app_date                    => true,  -- If true, include export date and time in the result.
      p_app_public_reports          => true,  -- If true, include public reports that a user saved.
      p_app_private_reports         => false, -- If true, include private reports that a user saved.
      p_app_notifications           => false, -- If true, include report notifications.
      p_app_translations            => true,  -- If true, include application translation mappings and all text from the translation repository.
      p_app_pkg_app_mapping         => false, -- If true, export installed packaged applications with references to the packaged application definition. If FALSE, export them as normal applications.
      p_app_original_ids            => false, -- If true, export with the IDs as they were when the application was imported.
      p_app_subscriptions           => true,  -- If true, components contain subscription references.
      p_app_comments                => true,  -- If true, include developer comments.
      p_app_supporting_objects      => null,  -- If 'Y', export supporting objects. If 'I', automatically install on import. If 'N', do not export supporting objects. If null, the application's include in export deployment value is used.
      p_app_include_single_file     => false, -- If true, the single sql install file is also included beside the splitted files.
      p_app_build_status_run_only   => false, -- If true, the build status of the app will be overwritten to RUN_ONLY.
      -- ORDS Modules (only available, when ORDS is installed):
      p_include_ords_modules        => false, -- If true, include ORDS modules of current user/schema.
      -- Schema Objects:
      p_include_object_ddl          => false, -- If true, include DDL of current user/schema and all its objects.
      p_object_type_like            => null,  -- A comma separated list of like expressions to filter the objects - example: '%BODY,JAVA%' will be translated to: ... from user_objects where ... and (object_type like '%BODY' escape '\' or object_type like 'JAVA%' escape '\').
      p_object_type_not_like        => null,  -- A comma separated list of not like expressions to filter the objects - example: '%BODY,JAVA%' will be translated to: ... from user_objects where ... and (object_type not like '%BODY' escape '\' and object_type not like 'JAVA%' escape '\').
      p_object_name_like            => null,  -- A comma separated list of like expressions to filter the objects - example: 'EMP%,DEPT%' will be translated to: ... from user_objects where ... and (object_name like 'EMP%' escape '\' or object_name like 'DEPT%' escape '\').
      p_object_name_not_like        => null,  -- A comma separated list of not like expressions to filter the objects - example: 'EMP%,DEPT%' will be translated to: ... from user_objects where ... and (object_name not like 'EMP%' escape '\' and object_name not like 'DEPT%' escape '\').
      p_object_view_remove_col_list => true,  -- If true, the outer column list, added by Oracle on views during compilation, is removed
      -- Table Data:
      p_include_data                => false, -- If true, include CSV data of each table.
      p_data_as_of_minutes_ago      => 0,     -- Read consistent data with the resulting timestamp(SCN).
      p_data_max_rows               => 1000,  -- Maximum number of rows per table.
      p_data_table_name_like        => null,  -- A comma separated list of like expressions to filter the tables - example: 'EMP%,DEPT%' will be translated to: where ... and (table_name like 'EMP%' escape '\' or table_name like 'DEPT%' escape '\').
      p_data_table_name_not_like    => null,  -- A comma separated list of not like expressions to filter the tables - example: 'EMP%,DEPT%' will be translated to: where ... and (table_name not like 'EMP%' escape '\' and table_name not like 'DEPT%' escape '\').
      -- General Options:
      p_include_templates           => true,  -- If true, include templates for README.md, export and install scripts.
      p_include_runtime_log         => true,  -- If true, generate file plex_runtime_log.md with detailed runtime infos.
      p_include_error_log           => true,  -- If true, generate file plex_error_log.md with detailed error messages.
      p_base_path_backend           => 'app_backend',      -- The base path in the project root for the Schema objects.
      p_base_path_frontend          => 'app_frontend',     -- The base path in the project root for the APEX app.
      p_base_path_web_services      => 'app_web_services', -- The base path in the project root for the ORDS modules.
      p_base_path_data              => 'app_data'));       -- The base path in the project root for the table data.
  END backapp;
SELECT backapp FROM dual;
```

ATTENTION: Exporting all database objects can take some time. I have seen huge runtime differences from 6 seconds for a small app up to several hundred seconds for big apps and/or slow databases. This is normally not the problem of PLEX. If you are interested in runtime statistics of PLEX, you can inspect the delivered `plex_runtime_log.md` in the root directory.<br>
Also, the possibility to export the data of your tables into CSV files does not mean that you should do this without thinking about it. The main reason for me to implement this feature was to track changes on catalog tables by regularly calling this export feature with a sensitive table filter and max rows parameter as catalog data is often relevant in business logic.

If you have organized your app into multiple schemas as described in [The Pink Database Paradigm][pinkdb], you may need to export database objects from more then one schema. This is no problem for PLEX.BackApp as all parameters are optional - you can simply logon to your second or third schema and extract only the DDL for these schemas by omitting the `p_app_id` parameter and setting `p_include_object_ddl` to `true`. Then unload the DDL files into a different directory - for example `app_backend_schemaName`.

A last word: you should inspect all the exported files and scripts and check if this solution can work for you. If not, please let me know what is missing or what should be done in a different way ...

Feedback is welcome - simply create a [new issue][plex_issue] at the [GitHub project page][plex_project]



Next Steps
-----------

It is up to you how you organize the version control repository and how often you export your APEX app or object DDL. I would follow the files first approach and extract the object DDL only ones to have a starting point. The APEX application needs regular exports - if you like, you can automate this.

Following the files first approach is sometimes not easy when you are using low code tools like [Quick SQL][quick_sql] and [Blueprint][blueprint] in APEX or code generators like [OraMUC's Table API Generator][om_tapigen]. There could be a need to regularly extract (maybe unknown) objects (not created by yourself) into version control to understand and document what you got from others (people or generators)...

If the directory structure provided by PLEX does not match your needs - no problem - you can align it. Simply loop over the returned file collection and do your necessary work - here an example:

```sql
DECLARE
  l_files plex.tab_export_files; -- before PLEX v2 it was apex_t_export_files
BEGIN
  l_files := plex.backapp(p_app_id => 100);
  FOR i IN 1..l_files.count LOOP
    -- relocate APEX app files from app_frontend to app_ui
    IF l_files(i).name LIKE 'app_frontend/%' THEN
      l_files(i).name := replace(l_files(i).name, 'app_frontend/', 'app_ui/');
      l_files(i).contents := replace(l_files(i).contents, 'prompt --app_frontend/', 'prompt --app_ui/');
    END IF;
    -- correct file links in install script
    IF l_files(i).name = 'scripts/install_frontend_generated_by_apex.sql' THEN
      l_files(i).contents := replace(l_files(i).contents, '@../app_frontend/', '@../app_ui/');
    END IF;
  END LOOP;

  -- more alignments...
END;
```

For unloading the resulting file collection with SQL\*Plus, please have a look in the `scripts/templates` folder of your export - there are examples to do this. See also my previous post on [how to handle the apex_t_export_files type returned by the APEX_EXPORT package with SQL\*Plus][prev_post].

Some people prefer to devide their DDL scripts into the two categories __restartable__ (like packages) and __run once__ (like tables). Others like to have their scripts in a way that they are always restartable and the DDL script itself takes care about doing the work only once when needed. The advantage of the second way is that your backend install/deployment script is always the same and it simply calls all objects DDL scripts.

There is no right or wrong in doing it this or that way - each project/team has its specific requirements and history. The important thing is, that you start to use a version control system to be able to log your changes and document your code.

By the way - PLEX provides script templates and object DDL that follows the second approach: You can always have the same install/deployment script and the DDL scripts are restartable - check it out by looking in one of your exported table DDL scripts.

You are now at the point where PLEX can't do anything more for you. If you like to export your object DDL scripts more often, you have to find a way to be able to protect some of your scripts against overwriting. Imagine you had to add two columns to a table and you provided a restartable alter statement for this in the existing DDL script. If you export this table script the next time with PLEX (or with dbms_metadata.get_ddl, which is used in the background), your alter statements are gone and the new columns are simply listed in the create table statement. With this script you are not be able to deploy your changes to TEST or PROD.<br>
One solution is to copy the original table script and name it e.g. `EMPLOYEES.dev.sql`. In this script you maintain the restartable alter statements. If you run PLEX.BackApp again you are overwrite save. The script `EMPLOYEES.sql` reflects your current table definition and can still be executed - it does nothing because the table is already existing. The script `EMPLOYEES.dev.sql` reflects your development history and need to be added to your custom install/deployment script.

As you can see, PLEX can do only the basics for you. It is up to the developers how they manage their version control repository and how they do their deployments - there are thousends of ways to do it ...



Inspirations / Further Reading
-------------------------------

Thanks are going to:

- André Borngräber for his ability to think and discuss database topics in deep details
- Blain Carter for his thoughts on [CI/CD for Database Developers – Export Database Objects into Version Control][post-blain]
- Markus Dötsch for the first BackApp tests and cross-reading the first version of this post
- Martin D'Souza for his time and the interesting discussion about code generation and version control at the APEX Connect 2018 in Düsseldorf, Germany and his blog post [Exporting APEX Application in SQLcl with Build Status Override][post_martin] - PLEX.BackApp has now a parameter for this ;-)
- Philipp Salvisberg for his thoughts on [The Pink Database Paradigm][pinkdb]
- Samuel Nitsche for his thoughts on [There is no clean (database) development without Version Control][post-samuel]
- Tim Hall for his article about [Generating CSV Files][article_tim]



Thats It
---------

Hope PLEX.BackApp helps someone else.

Happy coding, apexing, version controlling :-)<br>
Ottmar



[apex_export]: https://docs.oracle.com/database/apex-18.1/AEAPI/APEX_EXPORT.htm
[article_tim]: https://oracle-base.com/articles/9i/generating-csv-files
[blueprint]: https://docs.oracle.com/database/apex-18.1/HTMDB/using-blueprints.htm
[om_tapigen]: https://github.com/OraMUC/table-api-generator
[pinkdb]: https://www.salvis.com/blog/2018/07/18/the-pink-database-paradigm-pinkdb/
[plex_download]: https://github.com/ogobrecht/plex/releases/latest
[plex_issue]: https://github.com/ogobrecht/plex/issues/new
[plex_project]: https://github.com/ogobrecht/plex
[post_martin]: https://www.talkapex.com/2018/07/exporting-apex-application-in-sqlcl-with-build-status-override/
[post-blain]: https://learncodeshare.net/2018/07/16/ci-cd-for-database-developers-export-database-objects-into-version-control/
[post-samuel]: https://cleandatabase.wordpress.com/2017/09/22/there-is-no-clean-database-development-without-version-control/
[prev_post]: https://ogobrecht.github.io/posts/2018-07-25-apex-export-and-version-control
[quick_sql]: https://apex.oracle.com/quicksql/
