---
title: Markdown for Oracle APEX
description: A dynamic action type plugin
tags: [project, oracle, apex, plugin, markdown]
publishdate: 2016-01-01
lastmod: 2017-08-12 20:05:00
---

Some years ago I implemented a task board in APEX. For commenting I used the [stackexchange][1] [markdown implementation][2] ([old Google code repo][3]), which is a pure JavaScript converter and editor and based on [showdown.js][4].

Some months ago I had to implement an application, which should be able to have multiple editors on one page and the editors should be able to support a read only mode. Furthermore there were hard limits for the amount of text for each editor. Both things which are not so easy to implement with the rich text editor in APEX - no really read only mode and the amount of text is also a problem because of the HTML overhead.

It was time to rethink my old implementation and to build a plugin, which creates for each text area with the class markdown an own editor. All other non input elements with a class markdown should simply rendered to HTML, which is then also the solution for the read only mode of the editors. APEX standard text area items supports a read only mode and the class markdown from the text area is also rendered by the APEX engine for this mode :-)

The nice side effect is, that I don't had to reinvent the wheel by creating an own item type - I could reuse the standard APEX text area item and things like the character counter working out of the box.

You can find the sources and more informations on [GitHub][5] and a demo app on [apex.oracle.com][6].

Happy coding :-)<br>
Ottmar

[1]: https://stackexchange.github.io
[2]: https://github.com/balpha/pagedown
[3]: https://code.google.com/archive/p/pagedown/
[4]: https://github.com/showdownjs/showdown
[5]: https://github.com/ogobrecht/markdown-apex-plugin
[6]: https://apex.oracle.com/pls/apex/f?p=66154
