+++
title = "HydeBar"
date = "2017-11-29"
description = "A Jekyll Sidebar Template"
slug = "hydebar"
aliases = ["/posts/2017-11-29-hydebar/"]

[taxonomies]
tags = ["Generator", "HTML"]
+++

Earlier this year I wrote at the end of [this post](/blog/dokuwiki-plugin-revealjs):

> PS: In the meantime I switched complete to Markdown and [Jekyll](https://jekyllrb.com), a static site generator - but this is another story for another post ...

As always - it took a bit longer then expected. In the meantime I was fiddling around with Jekyll and modifying the default theme Minima to my needs. Then I stumbled over the [JSDoc theme Minami](https://github.com/nijikokun/minami) and the [Liquid docs site](https://shopify.github.io/liquid/) - both with nice sidebars. I wanted to have such a nice sidebar for my dev blog and began to look deeper how it was implemented. To my surprise the sidebar from the JSDoc theme Minami was complete CSS driven - cool.

It took me a while to full understand how it was working. With this knowledge and the design inspirations I was able to improve the Jekyll default theme to a sidebar template. As a bonus I integrated the HTML based slideshow library Reveal.js - you can write now your blog posts and slides with markdown.

The nice thing about blogging with markdown is, that you don't need to switch your tools - you use the usual ones from the daily programming job. It goes even better when you use GitHub: You commit your changes and GitHub takes care about generating your blog content from your sources. And the result is a fast and secure static site.

I had a accepted talk at the [DOAG Conference + Exhibition 2017](https://2017.doag.org/en/home/) in the stream "Strategy & Business Practices" about blogging for developers with Jekyll. Unfortunately short before I had an accident and broke my right upper arm :-(

My colleague Markus Dötsch was taking over the presentation and I concentrated on delivering the free time project "Jekyll sidebar template". This was the working title before I renamed it to "HydeBar" - a play with "Dr. Jekyll and Mr. Hyde" and the fact, that it is a sidebar template.

Yesterday I released version 1.0.0. You can start blogging for free in five minutes with this [quick start guide](https://ogobrecht.github.io/hydebar/features#quickstart-online-in-5-minutes). The [online demo](https://ogobrecht.github.io/hydebar) is serving as template, documentation and showcase. The mentioned slides from the [DOAG Conference](https://2017.doag.org/en/home/) are included in this demo (in German, sorry...).

Happy blogging :-)

Ottmar
