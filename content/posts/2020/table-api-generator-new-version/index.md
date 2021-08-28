---
title: New Version of Oracle Table API Generator Available
description: Bulk processing, support for audit and row version columns and more
tags: [Oracle, PL/SQL, Generator, oddgen]
slug: new-version-of-oracle-table-api-generator-available
publishdate: 2020-12-26
lastmod: 2020-12-27 15:00:00
---

Short before Christmas André and I released version 0.6.0 of our [table API generator](https://github.com/OraMUC/table-api-generator). The last release was exactly two years ago - time flies. This blog post highlights some of the changes - the [complete changelog is available on GitHub](https://github.com/OraMUC/table-api-generator/blob/master/docs/changelog.md#060-2020-12-20).

{{< toc "Table of Contents" >}}

## Bulk Processing

When you split your app over multiple schemas for higher data security you might need at some point the possibility to bulk process your data. Imagine the following, common schema setup (also see this nice [video by Connor McDonald](https://www.youtube.com/watch?v=OF7qR5lAmiw), 20 minutes):

- Data Schema: Holds your tables and provides table APIs for the other schemas, which have only select rights on the tables (or views) and execute rights on the table APIs
- API Schema: Holds your business logic and provides business APIs to the app parsing schema
- UI Schema: Has no own objects, only connect rights and is used as the parsing schema to run the application

This setup follows the principle of the least privilege. When you need to bulk process your data in the business logic (API schema), then you have a problem without bulk processing facilities in your table APIs. You need to implement business logic in the data schema or you grant update and/or delete rights to the API schema. The first solution is against the separation of concerns and the second one lowers your data security and maybe prevents you from not having triggers (more about this later in the audit columns section).

That is why we have now also bulk processing in the core of our generated table APIs. Here is how you can use it in your business logic:

```sql
/* EXAMPLE INSERT
To keep the memory usage low we break our inserts into 
a bulk size of 1000 rows. You should adapt the bulk size
to your use case. */ 
declare
  l_rows_tab     data_schema.your_table_api.t_rows_tab;
  l_number_bulks integer := 100;
  l_bulk_size    integer := 1000;
begin
  l_rows_tab := data_schema.your_table_api.t_rows_tab();
  l_rows_tab.extend(l_bulk_size);

  <<number_bulks>>
  for z in 1 .. l_number_bulks loop

    <<bulk_size>>
    for i in 1 .. l_bulk_size loop
      l_rows_tab(i).column_1 := your_logic_here;
      l_rows_tab(i).column_2 := your_logic_here;
    end loop bulk_size;

    data_schema.your_table_api.create_rows(l_rows_tab);
    commit;

  end loop number_bulks;
end;
/
```

```sql
/* EXAMPLE UPDATE */ 
declare
  l_rows_tab   data_schema.your_table_api.t_rows_tab;
  l_ref_cursor data_schema.your_table_api.t_strong_ref_cursor;
begin
  -- optionally set bulk limit, default is 1000
  -- data_schema.your_table_api.set_bulk_limit(500);
  open l_ref_cursor for 
    select * from app_users where your_conditions_here;

  <<outer_bulk>>
  loop
    l_rows_tab := data_schema.your_table_api.read_rows(l_ref_cursor);

    <<inner_data>>
    for i in 1 .. l_rows_tab.count
    loop
      --do your business logic here
      l_rows_tab(i).column_1 := your_logic_here;
    end loop inner_data;

    data_schema.your_table_api.update_rows(l_rows_tab);
    commit;

    exit when data_schema.your_table_api.bulk_is_complete;
  end loop outer_bulk;

  close l_ref_cursor;
end;
/
```

The bulk deletion works the same way as the bulk update - the difference is that you do not modify your data before calling the `delete_rows` method.

For more examples see the docs:

- [Basic usage](https://github.com/OraMUC/table-api-generator/blob/master/docs/bulk-processing.md)
- [Performance tests](https://github.com/OraMUC/table-api-generator/blob/master/docs/bulk-processing-performance.md)

## Support for Audit Columns

Keeping the bulk processing in mind for performance reasons it is a bad idea to have triggers only to manage audit columns in a table. If you have your tables in an own schema and the business logic and the app cannot directly write to the tables then it is easy to prevent triggers. Therefore the table APIs need to support that and hides the audit columns for insert or update operations. This is what our generator now supports.

You can map your specific audit column names to the four often used names `created`, `created_by`, `updated` and `updated_by` by providing a mapping string to the new parameter `p_audit_column_mappings` - an example:

```sql
-- TABLE DEFINITION --
create table app_users (
  au_id          integer            generated always as identity,
  au_first_name  varchar2(15 char)                         ,
  au_last_name   varchar2(15 char)                         ,
  au_email       varchar2(30 char)               not null  ,
  au_active_yn   varchar2(1 char)   default 'Y'  not null  ,
  -- This is only for demo purposes. In reality we expect
  -- more unified names and types for audit columns.
  au_created_on  date                            not null  ,
  au_created_by  char(15 char)                   not null  ,
  au_updated_at  timestamp                       not null  ,
  au_updated_by  varchar2(15 char)               not null  ,
  --
  primary key (au_id),
  unique (au_email),
  check (au_active_yn in ('Y', 'N'))
);

begin
  om_tapigen.compile_api(
    p_table_name            => 'APP_USERS',
    p_audit_column_mappings => 'created=#PREFIX#_CREATED_ON, created_by=#PREFIX#_CREATED_BY, updated=#PREFIX#_UPDATED_AT, updated_by=#PREFIX#_UPDATED_BY'
  );
end;
/
```

The `#PREFIX#` in our example is optional (determined automatically by the generator) and replaced with the found column_prefix `au`. Doing it this way you can provide always the same audit column mapping to all of your tables. I know some people hate column prefixes - but if you design your data models this way the generator can save you the work to align the mapping for each table.

## Support for a Row Version Column

The same reasons with triggers for the audit columns are valid for the support of a row version column. This can also be handled by our generator:

```sql
begin
  om_tapigen.compile_api(
    p_table_name                 => 'YOUR_TABLE',
    p_row_version_column_mapping => '#PREFIX#_VERSION_ID=tag_global_version_sequence.nextval'
  );
end;
/
```

You can also see here the before mentioned `#PREFIX#` substitution. The difference is that you define here only your column and for the column the SQL expression which should be used for the row version column - in this case, a sequence.

What we cannot do here is to add always 1 to the previous value like it is possible in a trigger - the table API has no idea what the previous value was. So, we are a little bit limited to a SQL expression but the point is, you can let the generated API manage the row version column without having a trigger.

## Tenant Support

This is the third new column mapping definition. For all people who have not an enterprise version with the VPD (virtual private database) functionality you can define a tenant expression for one of your columns:

```sql
begin
  om_tapigen.compile_api(
    p_table_name            => 'YOUR_TABLE',
    p_tenant_column_mapping => '#PREFIX#_TENANT_ID=to_number(sys_context(''my_sec_ctx'',''my_tenant_id''))'
  );
end;
/
```

For more information see the [parameter docs for p_tenant_column_mapping](https://github.com/OraMUC/table-api-generator/blob/master/docs/parameters.md#p_tenant_column_mapping-since-v060).

## More

- A new optional 1:1 view can be generated (new parameter `p_enable_one_to_one_view`)
- All generated object names can now be customized (new parameters `p_dml_view_name`, `p_dml_view_trigger_name` and `p_one_to_one_view_name`)
- Double quoting of table and column names in the generated code can now be configured (new parameter `p_double_quote_names`, default true)
- A new helper function `get_default_row` will be generated, when parameter `p_enable_column_defaults` is set to true (to support the row based create_row function)
- We have now unit tests driven by utPLSQL (it will be a permanent task to improve the tests with every new feature or bugfix, more about the special things of unit testing for a generator will follow in a future post)

## Breaking Changes

Where there is light, there is also shadow.

All the new features like bulk processing and audit column support make it hard, if not impossible, to generate a generic change log during the row processing. Also the check, if we have a modification and omit an update if not necessary is hard to implement and not good for the performance with the evolved generator. So we skipped the mentioned functionality.

As far as we know not many people use the generic changelog. If you do, you have to stick with the previous generator version or you have to find an alternative way to do it in the future. A good way seems to be the use of the Flashback Data Archive as it is performant and available in all database editions for free - and you can load existing data into the archive (see Tims article below):

- Blog post by Connor McDonald: [Triggers can provide auditing information, but there’s a future in flashback](https://blogs.oracle.com/oraclemagazine/a-fresh-look-at-auditing-row-changes)
- Blog post by Tim Hall: [Flashback Data Archive (FDA) Enhancements in Oracle Database 12c Release 1 (12.1)](https://oracle-base.com/articles/12c/flashback-data-archive-fda-enhancements-12cr1)
- Video by Connor McDonald: [Flashback Data Archive](https://www.youtube.com/watch?v=qIs2UPIodQg) (14 minutes)
- Video APEX Connect 2020 by Connor McDonald: [Flashback – so much more](https://www.youtube.com/watch?v=gqX91080r7A) (47 minutes)
- Video AskTOM Office Hours by Chris Saxon: [The Incredible Flashback Data Archive](https://www.youtube.com/watch?v=q81_UDnEpIs) (53 minutes)

And the last Breaking change is, that you need at least Oracle DB 12.1 or higher. That should (hopefully) no problem for the most projects.

## Conclusion

A big THANK YOU to all contributors - the current version of the generator would not be possible without your feedback and help.

Be sure to test the new generator before migrating to it. We use it already in some projects and it should be pretty stable. Nevertheless, with so many changed things we cannot give you a guarantee for every edge case - by using it you accept the MIT license. Please check out the [project page at GitHub](https://github.com/OraMUC/table-api-generator) and [open an issue](https://github.com/OraMUC/table-api-generator/issues/new/choose) if you encounter a problem.

A happy new year and happy coding :-)

Ottmar
