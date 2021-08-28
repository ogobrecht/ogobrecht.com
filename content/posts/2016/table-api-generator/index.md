---
title: Table API Generator
description: An Oracle PL/SQL package with SQL Developer integration
tags: [Open source project, Oracle, PL/SQL, Generator, oddgen]
slug: table-api-generator
publishdate: 2016-06-10
lastmod: 2017-08-12 20:07:00
---

Last year I needed for a project a simple table API, which is able to generate a generic change log - something like "show me for table xyz which column was changed when and what was the old value and what is the new one". Only changed values should be stored and all tables should log into the same generic logging table. Sounds like we need a generator for this.

Unfortunately there was no time in the project to create such a generator from the ground. Luckily André, a colleague of me, had started to implement such an API generator in his free time and I had only to implement the generic change log functionality - also in my free time. Our API generator open source project was born :-)

Later on I needed a function to get the id from an record by the unique columns - next feature for the API generator: generate a (overloaded) function for each unique constraint on a table. Now it is a simple function call to get the id:

```sql
your_var := your_table_name_api.get_pk_by_unique_cols(
    p_column_name_1 => 'xyz',
    p_column_name_2 => 123,
    ...);
```

The API is also handling the case, when no data is found and everything without the need to look in the dictionary for the unique columns of that table or to write boilerplate code and possibly forget one column.

The next thing for APEX was "For tabular forms you can't use APIs". We came up with the idea to generate a view for each table with an instead of trigger for inserts, updates and deletions. The trigger is simply calling the API. Now you can use APEX own "automatic row processing" and the generic logging together.

In my holiday this spring I stumbled over a tweet from Phillip Salvisberg about his [oddgen project][1], a SQL Developer extension to invoke dictionary-driven code generators. I was thrilled, we can have a SQL Developer integration by writing a small PL/SQL wrapper for oddgen. I finished the integration in my holiday, I could not wait.

Over the time we found out, that the generation of the thin API wrappers for our tables saves us time and makes our code more stable and readable because of the saved boilerplate code.  
Business logic packages becomes invalid after table changes and API regeneration. This is good, because you can see, which API calls are now invalid. If you have simple insert or update statements you might oversee some places, where the statement is still valid for example with an added table column, but in fact does the wrong insert or update.

And the last thing, what is now possible: Security - separate the data from the user interface. Simply grant execute rights on the API and business logic packages to the UI schema and disable the deletion of rows in your API packages when you don't need it. No user will be able to drop or truncate your tables, because there are no tables in the UI schema.

The generated API packages are really thin - nothing special at all. Nevertheless they are powerful time savers.

You can find the sources and more informations on [GitHub][2].

Happy coding :-)

Ottmar

[1]: https://www.oddgen.org
[2]: https://github.com/OraMUC/table-api-generator
