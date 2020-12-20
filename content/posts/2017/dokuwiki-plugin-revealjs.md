---
title: DokuWiki Plugin Reveal.js
description: My contributions to an existing DokuWiki slideshow plugin
tags: [project, dokuwiki, plugin, revealjs, php]
lang: en
publishdate: 2017-03-05
lastmod: 2017-08-12 20:09:00
---
[DokuWiki][1] is very good for creating documentation in a team. It is PHP based, needs less resources and is running without a database only on files on nearly every webserver. If your infrastructure is crashed for whatever reason and you have at least access to the files (on the webserver or in a backup) you can read your documentation with a simple text editor, because DokuWiki's syntax is designed to be readable as possible without any rendering to HTML.

For the APEX connect 2015 I started to use Markdown and [Pandoc][2] to create HTML based slides. Pandoc supports different HTML slideshow tools - two of them are also available as plugins in DokuWiki: S5 and [Reveal.js][3]. Reveal.js is the more modern library and I used this one together with Pandoc.

For the DOAG conference last year I tried to use Reveals.js as a DokuWiki Plugin - I wanted to have at the same time a normal wiki page and the possibility to render this page as a slideshow. Unfortunately the existing plugin was only a base implementation and many features from Reveal.js were not available. I decided to contribute to the existing plugin. The list of my improvements is long - I had fun and learned a lot. The plugin can be found [here on the DokuWiki homepage][4].

Happy presenting :-)<br>
Ottmar

P.S.: In the meantime I switched complete to Markdown and [Jekyll][5], a static site generator - but this is another story for another post ...

[1]: https://www.dokuwiki.org
[2]: http://pandoc.org
[3]: http://lab.hakim.se/reveal-js
[4]: https://www.dokuwiki.org/plugin:revealjs
[5]: https://jekyllrb.com
