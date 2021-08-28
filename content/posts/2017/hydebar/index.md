---
title: HydeBar
description: A Jekyll Sidebar Template
tags: [Open source project, Generator, HTML]
slug: hydebar
publishdate: 2017-11-29
lastmod: 2017-12-01 20:00:00
---

Earlier this year I wrote at the end of [this post][1]:

> P.S.: In the meantime I switched complete to Markdown and [Jekyll][2], a static site generator - but this is another story for another post ...

As always - it took a bit longer then expected. In the meantime I was fiddling around with Jekyll and modifying the default theme Minima to my needs. Then I stumbled over the [JSDoc theme Minami][3] and the [Liquid docs site][4] - both with nice sidebars. I wanted to have such a nice sidebar for my dev blog and began to look deeper how it was implemented. To my surprise the sidebar from the JSDoc theme Minami was complete CSS driven - cool.

It took me a while to full understand how it was working. With this knowledge and the design inspirations I was able to improve the Jekyll default theme to a sidebar template. As a bonus I integrated the HTML based slideshow library Reveal.js - you can write now your blog posts and slides with markdown.

The nice thing about blogging with markdown is, that you don't need to switch your tools - you use the usual ones from the daily programming job. It goes even better when you use GitHub: You commit your changes and GitHub takes care about generating your blog content from your sources. And the result is a fast and secure static site.

I had a accepted talk at the [DOAG Conference + Exhibition 2017][5] in the stream "Strategy & Business Practices" about blogging for developers with Jekyll. Unfortunately short before I had an accident and broke my right upper arm :-(

My colleague Markus Dötsch was taking over the presentation and I concentrated on delivering the free time project "Jekyll sidebar template". This was the working title before I renamed it to "HydeBar" - a play with "Dr. Jekyll and Mr. Hyde" and the fact, that it is a sidebar template.

Yesterday I released version 1.0.0. You can start blogging for free in five minutes with this [quick start guide][6]. The [online demo][7] is serving as template, documentation and showcase. The mentioned slides from the [DOAG Conference][5] are included in this demo (in German, sorry...).

Happy blogging :-)

Ottmar

[1]: /posts/2017-03-05-dokuwiki-plugin-revealjs
[2]: https://jekyllrb.com
[3]: https://github.com/nijikokun/minami
[4]: https://shopify.github.io/liquid/
[5]: https://2017.doag.org/en/home/
[6]: https://ogobrecht.github.io/hydebar/features#quickstart-online-in-5-minutes
[7]: https://ogobrecht.github.io/hydebar
