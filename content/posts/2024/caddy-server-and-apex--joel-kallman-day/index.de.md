---
title: Caddy Server - APEX hinter einem vollautomatischem SSL Proxy #JoelKallmanDay
description: Vergiss selbstsignierte Zertifikate und Browser, die sich darüber beschweren
tags: [Oracle APEX, SSL, proxy, Caddy]
slug: caddy-server-and-apex--joel-kallman-day
publishdate: 2024-10-16
lastmod: 2024-10-16 12:00:00
featured_image: 
featured_image_alt: 
featured_image_caption: 
---

Wie die Zeit vergeht. Fast auf den Tag genau vor drei Jahren habe ich meinen letzten Blogeintrag geschrieben. Vielen Dank an Tim Hall und seine Erinnerung, mal wieder etwas zu schreiben für den [#Joel Kallman Day](https://oracle-base.com/blog/2024/09/27/joel-kallman-day-2024-announcement/).

Hast Du Dich schon einmal über Deinen Browser geärgert, dass er Dir in Deiner lokalen Entwicklungsumgebung immer mit roter Schrift in der URL zeigt, dass Du Dein SSL-Zertifikat selbst ausgestellt hast und es somit für Ihn ungültig ist?

Das muss nicht sein. Es gibt neben den großen Webservern wie [Apache](https://httpd.apache.org/) oder [NGINX](https://nginx.org/en/) noch eine ganze Menge andere. Einer davon is [Caddy](https://caddyserver.com/), der in Bezug auf automatisches SSL eine gewisse Sonderstellung einnimmt: Er bringt eine ganze SSL-Zertifizierungsstelle mit und kann lokal auf dem Rechner automatisch sein Root-Zertifikat in den Zertifikatsspeicher des Betriebssystem einbinden. Dann beschwert sich auch Dein Browser nicht mehr über ein ungültiges Zertifikat.

Die einzige Herausforderung bei Caddy ist, dass man herausfinden muss, wie man ihn konfiguriert, damit APEX sauber hinter ihm als Reverse-Proxy läuft. Leider ist das ein wenig kompliziert, nicht wegen Caddy, sondern wegen APEX bzw ORDS. Sagen wir es einmal so: APEX hinter einem Reverse-Proxy hat so seine Tücken.

Wer mehr darüber wissen möchte, findet eine Menge Blogbeiträge dazu - meistens geht dann um Apache oder NGINX. Ich wollte aber gerne die vollautomatische SSL-Terminierung von Caddy nutzen, daher musste ich mir mit Hilfe der vorhandenen Informationen anschauen, wie es mit Caddy gehen kann. Ein besonderer Dank geht dabei an meinen Kollegen Peter Raganitsch, der mir sowohl persönlich als auch mit seinem schon einige Jahre altem Blogeintrag zum Thema APEX und NGINX sehr geholfen hat - hier der Link: [The Oracle APEX Reverse Proxy Guide using NGINX](https://www.oracle-and-apex.com/the-oracle-apex-reverse-proxy-guide-using-NGINX/).

Viel Spaß mit Caddy :-)

Ottmar
