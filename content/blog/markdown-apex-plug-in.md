+++
title = "Markdown for Oracle APEX"
date = "2016-01-01"
description = "A dynamic action type plugin"
slug = "markdown-for-oracle-apex"
aliases = ["/posts/2016-01-01-markdown-for-oracle-apex/"]

[taxonomies]
tags = ["Oracle", "APEX", "Plug-in", "Markdown"]

[extra]
giscus = true
+++

Some years ago I implemented a task board in APEX. For commenting I used the [stackexchange](https://stackexchange.github.io) [markdown implementation](https://github.com/balpha/pagedown) ([old Google code repo](https://code.google.com/archive/p/pagedown/)), which is a pure JavaScript converter and editor and based on [showdown.js](https://github.com/showdownjs/showdown).

Some months ago I had to implement an application, which should be able to have multiple editors on one page and the editors should be able to support a read only mode. Furthermore there were hard limits for the amount of text for each editor. Both things which are not so easy to implement with the rich text editor in APEX - no really read only mode and the amount of text is also a problem because of the HTML overhead.

It was time to rethink my old implementation and to build a plugin, which creates for each text area with the class markdown an own editor. All other non input elements with a class markdown should simply rendered to HTML, which is then also the solution for the read only mode of the editors. APEX standard text area items supports a read only mode and the class markdown from the text area is also rendered by the APEX engine for this mode :-)

The nice side effect is, that I don't had to reinvent the wheel by creating an own item type - I could reuse the standard APEX text area item and things like the character counter working out of the box.

You can find the sources and more informations on [GitHub](https://github.com/ogobrecht/markdown-apex-plugin) and a demo app on [apex.oracle.com](https://apex.oracle.com/pls/apex/f?p=66154).

Happy coding :-)

Ottmar
