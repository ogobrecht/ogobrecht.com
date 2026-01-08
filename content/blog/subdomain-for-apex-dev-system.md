+++
title = "Why a subdomain for an APEX development system is a bad idea"
date = "2015-12-12"
description = "The Internet Explorer cookie desaster"
slug = "why-a-subdomain-for-an-apex-development-system-is-a-bad-idea"
aliases = ["/posts/2015-12-12-why-a-subdomain-for-an-apex-development-system-is-a-bad-idea/"]

[taxonomies]
tags = ["Oracle", "apex"]
+++

_Do you find dev.apex.mycompany.tld a nice, rememberable address? Unfortunately this will not work - at least when you use Internet Explorer (which is the standard browser in most companies) and you use the same cookie name in some or all applications to share the session across multiple applications._

## What is the problem on a subdomain?

Internet Explorer including version 11 has a really bad cookie implementation. If you login to your productive APEX instance under apex.mycompany.tld and then to your development instance under dev.apex.mycompany.tld, IE sends the session cookie from your productive instance to your development instance. You will not be able to login - the server is generating a new session each time because of the invalid session cookie.

It comes to a nightmare if you configured your systems for automatic login with the windows login credentials as described in [this document](http://de.slideshare.net/nielsdb/mt-ag-howtosingle-signonfuerapexanwendungen-mitkerberos) from Niels de Bruijn. The automatic login leads to hundreds new sessions in a few seconds - depending on the speed of your development system.

Not to mention that Chrome and Firefox are working well...

More details about IE's cookie desaster can be found on [blogs.msdn.com](http://blogs.msdn.com/b/ieinternals/archive/2009/08/20/wininet-ie-cookie-internals-faq.aspx) - the relevant question for this blog entry is number three.

Happy APEXing :-)

Ottmar
