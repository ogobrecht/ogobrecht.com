---
title: Caddy Server - APEX behind a fully automated SSL proxy #JoelKallmanDay
description: Forget self-signed certificates and browsers that complain about them
tags: [Oracle, APEX, SSL, proxy, Caddy]
slug: caddy-server-and-apex--joel-kallman-day
publishdate: 2024-10-16
lastmod: 2024-10-16 00:00:00
featured_image: pexels-ekrulila-2292837.jpg
featured_image_alt: Person with white scroll
featured_image_caption: Photo by Gül Işık on pexels.com
---

How time flies. Almost exactly three years ago to the day, I wrote my last blog post. Many thanks to Tim Hall and his reminder to write something again for [#JoelKallmanDay](https://oracle-base.com/blog/2024/09/27/joel-kallman-day-2024-announcement/).

{{< toc >}}

## Introduction

Have you ever been annoyed by the fact that your browser always shows you in red in the URL in your development environment that you have issued the SSL certificate yourself and that it is therefore invalid for it?

That doesn't have to be the case. In addition to the large web servers such as [Apache](https://httpd.apache.org/) or [NGINX](https://nginx.org/en/), there are many others. One of these is [Caddy](https://caddyserver.com/), which occupies a special position in terms of automatic SSL: It comes with an entire SSL certification authority and can automatically integrate its root certificate into the operating system's certificate store locally on the computer. Your browser will then no longer complain about an invalid certificate.

The only challenge with Caddy is that you need to know how to configure it so that APEX runs properly behind it as a reverse proxy. Unfortunately, this is a bit complicated, not because of Caddy, but because of APEX or ORDS. Let's put it this way: APEX behind a reverse proxy has its pitfalls. At least if you don't want to work on the standard port 443.

If you want to know more about it, you can find a lot of blog posts about it - mostly about Apache or NGINX. However, I wanted to use Caddy's fully automatic SSL termination, so I had to look at how it can be done with Caddy using the information available. Special thanks go to my colleague Peter Raganitsch, who helped me a lot both personally and with his blog entry on APEX and NGINX, which is already several years old - here is the link: [The Oracle APEX Reverse Proxy Guide using NGINX](https://www.oracle-and-apex.com/the-oracle-apex-reverse-proxy-guide-using-NGINX/).

## Installation

Caddy is written in [Go](https://go.dev/). The [Download](https://caddyserver.com/download?package=github.com%2Fcaddyserver%2Freplace-response) only ever includes a single binary file for the respective operating system. Caddy supports plugins to integrate additional functionality into the web server. Manipulating HTTP headers and redirecting URLs is of course basic functionality. Changing the content of the delivered web pages, on the other hand, is a functionality that must be retrofitted using a plugin. Since we need this, we have to initiate a so-called custom build so that the plugin is integrated into the binary file.

The download link above has already preselected the plugin. You only have to select the target operating system if it was not recognized correctly. This custom build mode is also the reason why it makes no sense to install Caddy with a package manager such as [Homebrew](https://brew.sh/) (Mac) or [Chocolatey](https://chocolatey.org/) (Windows). After downloading, you should add Caddy to the search path of your operating system to make it easier to access.

One more note: Caddy attempts to integrate its root certificate into the operating system's certificate store at startup. However, this requires libraries from the [Network Security Services (NSS)](https://firefox-source-docs.mozilla.org/security/nss/index.html), a Mozilla project (see also [Wikipedia](https://en.wikipedia.org/wiki/Network_Security_Services)). If Caddy cannot find these libraries, you will have to import the root certificate from Caddy yourself. I installed the libraries on my Mac with Homebrew (brew install nss) and it worked automatically (of course you will be asked for the admin password for this process). For Linux you can use the respective package manager. There is not really an installation option for Windows. Allegedly it should be enough to have Firefox installed, which then probably comes with the required nss3.dll (I have not verified this, I work with Chromium on a Mac).

## Caddy Configuration

Now the actual core of the blog post, the configuration. Caddy basically uses a JSON format for its configuration and can also be reconfigured at runtime without restarting via API (another special feature). However, there are a few adapters that can also read other formats when Caddy is started. The best-known format is probably the so-called Caddyfile, which is easier for people to read and write than a highly hierarchical JSON:

```txt
{
    order replace after encode
}

localhost:8001 {
    handle /ords/* {
        reverse_proxy http://localhost:7001 {
            header_down Location //localhost/ //localhost:8001/
            header_up Host localhost:8001
            header_up +HTTP_X-Forwarded-Port 8001
            header_up -Origin
        }
        replace {
            //localhost/ //localhost:8001/
        }
    }

    handle_path /i/* {
        root * ./images
        file_server
    }

    redir /ords /ords/
    redir / /ords/
}
```

The first block is outside a site and global options are defined in it. Here we place the `replace` plugin in the correct process order so that it works as desired (`order replace after encode`, see also the [plugin on GitHub](https://github.com/caddyserver/replace-response)).

Then comes the configuration for our local development server:

- `localhost:8001`: If Caddy recognizes a domain (including localhost), a certificate is automatically issued for the domain.
- `handle /ords/*`: Starts the configuration for the path `/ords/*`.
- `reverse_proxy http://localhost:7001`: We want to forward all `/ords/*` requests to the ORDS on port 7001.

Now comes the part where I wrote at the beginning that APEX behind a reverse proxy has its pitfalls. In an ideal world, it would not be necessary to tell Caddy more about the reverse proxy directive, as the usual headers are automatically set by Caddy so that the service behind it knows that the request has gone via a proxy server (X-Forwarded-*, see also the [documentation on this](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#headers)):

- `header_down Location //localhost/ //localhost:8001/`: header_down means in the direction of the browser, so we replace all location headers in which the port is missing with the correct information.
- `header_up Host localhost:8001`: header_up means direction ORDS, so we tell ORDS what the hostname and port is (unfortunately ORDS does not understand correctly and ignores the port information).
- `header_up +HTTP_X-Forwarded-Port 8001`: Note the small plus symbol. This means we are adding this header. I also tried `X-Forwarded-Port 8001`, but ORDS seems to ignore it. Fortunately, APEX is smart enough to honor the port information from multiple headers, so at least the URLs generated by APEX are correct.
- `header_up -Origin`: Here the small minus symbol means that the header should be deleted. We do this so that ORDS does not exit the game with cross origin errors. I actually configured ORDS so that this wouldn't be necessary, but it didn't work. If anyone has a better solution, please let me know (see the ORDS configuration below).
- `replace` and `//localhost/ //localhost:8001/`: The same game as before, only this time not with the headers, but with the content of the responses (response body) that the ORDS sends back due to REST calls (mostly JSON data). APEX is completely left out here.

Now standard functionality again:

- `handle_path /i/*` (and the following two lines): This is where we host our static APEX files such as JavaScript, CSS, etc., so that this does not have to be taken over by ORDS.
- `redir /ords /ords/`: Here we redirect requests to the correct path without a trailing slash
- redir `/ /ords/`: You should adapt this individually if you want to treat the root directory differently.

In defense of the ORDS, however, I have to say that you should work with the standard port 443 in a productive environment. This makes the problems behind a proxy much smaller or even disappear. But none of this helps if you can't fall back on the standard port. In my case, the port depends on which development branch I am currently in. I could be running several instances in parallel, so not every server can want to work on the same port...

## ORDS Configuration

Here is my sample configuration for the ORDS (settings.xml):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>Saved on Wed Oct 09 12:14:37 UTC 2024</comment>
<entry key="database.api.enabled">true</entry>
<entry key="debug.printDebugToScreen">true</entry>
<entry key="security.externalSessionTrustedOrigins">localhost:8001</entry>
<entry key="security.httpsHeaderCheck">X-Forwarded-Proto:https</entry>
<entry key="security.requestValidationFunction">ords_util.authorize_plsql_gateway</entry>
<entry key="http.cookie.filter.byValue">startsWith:ORA_WWV</entry>
<entry key="standalone.access.log">/path/to/your/access.log</entry>
<entry key="standalone.http.host">localhost</entry>
<entry key="standalone.http.port">7001</entry>
<entry key="standalone.context.path">/ords</entry>
<entry key="standalone.static.path">/path/to/the/apex/images</entry>
<entry key="standalone.static.context.path">/i/</entry>
<entry key="misc.defaultPage">apex</entry>
<entry key="jdbc.InitialLimit">10</entry>
<entry key="jdbc.MaxLimit">20</entry>
<entry key="jdbc.InactivityTimeout">60</entry>
</properties>
```

The two most important lines in relation to operation behind a reverse proxy:

```xml
<entry key="security.externalSessionTrustedOrigins">localhost:8001</entry>
<entry key="security.httpsHeaderCheck">X-Forwarded-Proto:https</entry>
```

The first line should actually help so that we don't have to delete the Origin header in the direction of ORDS, but it didn't work for me. The second line helps ORDS to recognize that the frontend server (reverse proxy) takes over the SSL termination. For a development server where both services run on localhost, I see no reason to secure the connection between the proxy and ORDS. That would go against my goal of using Caddy to benefit from a fully automated SSL solution. The situation is different for production environments, of course. Caddy can also secure the connection to ORDS.

## Start Caddy

If you have everything together and your Caddyfile is in the same directory where you start Caddy, then the start command is particularly short:

```sh
caddy run
```

If the configuration file is somewhere else:

```sh
caddy run --config /path/to/Caddyfile
```

If you want to call the configuration file something else, but it is saved in Caddyfile format:

```sh
caddy run --config /path/to/config.txt --adapter caddyfile
```

If you like, you can also register Caddy (and ORDS) as a service in your operating system so that you don't have to start the servers manually.

I myself have built a small development server with Node.js, which first generates the configuration files for Caddy and ORDS, then installs ORDS in the PDB (if not already done), and then starts Caddy and ORDS each in a child process. I can then simply terminate both at the same time with Ctrl + C. In addition, a different port is automatically used for each development branch (hence the ports 7001 and 8001 in my examples here, in another branch this could also be 7005 and 8005), so that I can run several instances in parallel (this works well with Git worktrees). So I work very flexibly on the command line and start the required development server with a short command in the respective branch. But that would be a topic for another blog entry.

## Conclusion

I like it when everything looks good on the SSL side of my development environments. Caddy really is a great help in this respect. You could even use Caddy to provide an internal certification server, which then supplies all web servers within a network with certificates. I use this for remote development instances so that I only have to install a single root certificate for all machines. More about this in the [official documentation](https://caddyserver.com/docs/caddyfile/directives/acme_server).

Maybe this blog entry will help some of you out there in the wide world.

Have fun with the Caddy Server :-)

Ottmar
