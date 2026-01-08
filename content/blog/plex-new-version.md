+++
title = "New Major Version of PL/SQL Export Utilities Available"
date = "2019-06-26"
description = "PLEX is now independent from an APEX installation"
slug = "new-major-version-of-plex-available"
aliases = ["/posts/2019-06-26-new-major-version-of-plex-available/"]

[taxonomies]
tags = ["Oracle", "APEX", "PL/SQL", "Version control"]

[extra]
giscus = true
+++

PLEX is a PL/SQL package with export utilities - see [this post](/blog/plex-plsql-export-utilities/) what it can do for you. In the past it was dependent on APEX for two reasons: The APEX_EXPORT package to allow exporting an APEX app and the APEX_ZIP package for compressing the resulting file collection to a zip file.

After the first public release of PLEX, I got a comment like "Nice tool, but I don't use APEX". I thought I should make PLEX independent from APEX to allow at least the export of all the schema DDL and also the table data. Some weeks ago Jürgen Schuster contacted me to try out PLEX for an switch from Subversion to Git for one of his customer projects. It turns out that PLEX was not able to export the schema DDL because of errors from DBMS_METADATA regarding many Java classes. And the second issue was that one of their machines had no APEX installed. This was the final trigger for me to rework the implementation of PLEX.

PLEX is now independent from an APEX installation. Thanks to Anton Scheffer for his [as_zip package](https://technology.amis.nl/2010/03/13/utl_compress-gzip-and-zlib/). PLEX reuses the methods for compressing files and uses conditional compilation to include/exclude functionality depending on APEX. Because PLEX cannot rely on APEX anymore, the return type for the methods **backapp** and **queries_to_csv** has changed from `apex_t_export_files` to `plex.tab_export_files`. This was unavoidable and if you have existing scripts and you want to update to the new PLEX version, you have to change the variables based on that return type. A simple search and replace will normally do the trick. This breaking change in the PLEX API is also the reason for a new major version.

The other improvement is better error handling and logging. Per default you will find two files in an export collection: plex_runtime_log and plex_error_log. The former is for an overview what happened and how long it took and the latter is for detailed error messages. If you encounter errors and you think that should not happen and is a problem of PLEX, then please open an [issue on GitHub](https://github.com/ogobrecht/plex/issues/new). I was able to export the schema APEX_19_0100 with around 5000 objects on my dev machine...

- [Project on Github](https://github.com/ogobrecht/plex)
- [Download latest version](https://github.com/ogobrecht/plex/releases/latest)

Happy exporting :-)

Ottmar
