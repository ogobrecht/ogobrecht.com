---
title: PLOC - Convert PL/SQL Code into Markdown Docs
description: Another way to document PL/SQL business logic
tags: [project, oracle, plsql, generator, converter, docs, npm]
lang: en
publishdate: 2019-01-10
lastmod: 2019-01-11 20:02:00
---

Some months ago I had to write a README file with Markdown syntax for a PL/SQL open source project. I changed function and procedure parameters of the package often during the implementation. Therefore, maintaining the documentation was no fun in the beginning. Maybe you know this from your own (payed) projects ;-)

Normally in the business world I see minimalistic comments in the code and a dedicated documentation independent of the code. As you can imagine, the latter is sometimes - let's say "out of date", if it exists at all ...

I don't want to discuss the reasons for this here - you all know several ones. And I also do not have a general solution for code documentation. But I have some ideas what is important for me:

- The base of a good PL/SQL code documentation is a good code structure
  - No single functions and procedures - packages with meaningful names are the way to go
- As I have the source code under version control in local files on my computer I need a command line tool for the doc generation - there is no need for a database connection
  - The CLI should be able to process multiple files (packages)
  - For my small open source project I have only one package and I want to define a document name different then the package name, so I need a CLI parameter for that
- Comments should be written directly after the package/function/procedure signature (in the package spec, optionally it should also work for triggers and types)
  - I want to use Markdown for the comments - this allows me to write also bigger text parts and code examples
- I don't want to describe all parameters in a JavaDoc manner
  - PL/SQL is strong typed, everything I need to know is visible in the signature of a function or procedure
  - Replicating the parameters for documentation is error prone and does not follow the DRY principles
  - With meaningful parameter names you need often no or only short comments - these can be placed directly after the parameters as single line comments
  - Long descriptions can be written in the Markdown main comment
- The package/function/procedure signature should be automatically included in the output as a code block for reference
- Output should also be Markdown - this can be easily read by humans and further processed by machines
  - Only documented functions/procedures should be included in the output to keep the focus on the important stuff
  - I want to have an automatic table of contents in each generated document
  - With the help of [Pandoc][pandoc] many formats like Word, RTF, PDF or HTML can be generated (for GitHub I only need Markdown)

There are already several open source projects available for PL/SQL code documentation generation:

- [PLDoc][pldoc]
- [OraDoclet][oradoclet]
- [SchemaSpy][schemaspy]
- [Natural Docs][natdocs]
- [PL/SQL to Markdown Documenter][plmddoc]

Only the last one is able to generate Markdown docs, but the input has to be in JavaDoc. All the others can produce HTML output and often some other formats like RTF, Word or PDF. Natural Docs has a Markdown like simple text syntax, but also no Markdown output. Some of the tools can automatically document a whole schema - that is not the focus of PLOC. Most comparable is the intention of PL/SQL to Markdown  Documenter.

So I had to do it by myself. I called it PLOC (PLDoc was already used, so I skipped the D...) and it is implemented in JavaScript as a npm package and currently used by me for the following two projects: [PL/SQL Export Utilities][plex] and [Oracle Table API Generator][tapigen]. It is very lightweight - the main code without the CLI has currently less characters as the Markdown source of this blog post. Maybe it is also useful for you. If not, have a look at the other mentioned projects.

More infos about [PLOC][ploc] itself can be found on the [project page][ploc].

Happy coding and documenting :-)<br>
Ottmar



[natdocs]: https://www.naturaldocs.org/
[oradoclet]: http://oradoclet.sourceforge.net/
[pandoc]: https://pandoc.org/
[pldoc]: http://pldoc.sourceforge.net/
[plex]: https://github.com/ogobrecht/plex
[plmddoc]: https://github.com/OraOpenSource/plsql-md-doc
[ploc]: https://github.com/ogobrecht/ploc
[schemaspy]: http://schemaspy.sourceforge.net/
[tapigen]: https://github.com/OraMUC/table-api-generator
