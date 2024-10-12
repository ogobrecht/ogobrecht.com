---
title: Caddy Server - APEX hinter einem vollautomatischem SSL Proxy #JoelKallmanDay
description: Vergesst selbstsignierte Zertifikate und Browser, die sich darüber beschweren
tags: [Oracle, APEX, SSL, proxy, Caddy]
slug: caddy-server-and-apex--joel-kallman-day
publishdate: 2024-10-16
lastmod: 2024-10-16 12:00:00
featured_image: 
featured_image_alt: 
featured_image_caption: 
---

Wie die Zeit vergeht. Fast auf den Tag genau vor drei Jahren habe ich meinen letzten Blogeintrag geschrieben. Vielen Dank an Tim Hall und seine Erinnerung, mal wieder etwas zu schreiben für den [#JoelKallmanDay](https://oracle-base.com/blog/2024/09/27/joel-kallman-day-2024-announcement/).

{{< toc >}}

## Einleitung

Habt Ihr Euch schon einmal über Euren Browser geärgert, dass er Euch in Eurer lokalen Entwicklungsumgebung immer mit roter Schrift in der URL zeigt, dass Ihr das SSL-Zertifikat selbst ausgestellt habt und es somit für ihn ungültig ist?

Das muss nicht sein. Es gibt neben den großen Webservern wie etwa [Apache](https://httpd.apache.org/) oder [NGINX](https://nginx.org/en/) noch eine ganze Menge andere. Einer davon is [Caddy](https://caddyserver.com/), der in Bezug auf automatisches SSL eine gewisse Sonderstellung einnimmt: Er bringt eine ganze SSL-Zertifizierungsstelle mit und kann lokal auf dem Rechner automatisch sein Root-Zertifikat in den Zertifikatspeicher des Betriebssystem einbinden. Dann beschwert sich auch Euer Browser nicht mehr über ein ungültiges Zertifikat.

Die einzige Herausforderung bei Caddy ist, dass man herausfinden muss, wie man ihn konfiguriert, damit APEX sauber hinter ihm als Reverse-Proxy läuft. Leider ist das ein wenig kompliziert, nicht wegen Caddy, sondern wegen APEX bzw ORDS. Sagen wir es einmal so: APEX hinter einem Reverse-Proxy hat so seine Tücken.

Wer mehr darüber wissen möchte, findet eine Menge Blogbeiträge dazu - meistens geht es dann um Apache oder NGINX. Ich wollte aber gerne die vollautomatische SSL-Terminierung von Caddy nutzen, daher musste ich mir mit Hilfe der vorhandenen Informationen anschauen, wie es mit Caddy gehen kann. Ein besonderer Dank geht dabei an meinen Kollegen Peter Raganitsch, der mir sowohl persönlich als auch mit seinem schon einige Jahre altem Blogeintrag zum Thema APEX und NGINX sehr geholfen hat - hier der Link: [The Oracle APEX Reverse Proxy Guide using NGINX](https://www.oracle-and-apex.com/the-oracle-apex-reverse-proxy-guide-using-NGINX/).

## Installation

Caddy ist in [Go](https://go.dev/) geschrieben. Der [Download](https://caddyserver.com/download?package=github.com%2Fcaddyserver%2Freplace-response) umfasst immer nur eine einzige Binärdatei für das jeweilige Betriebssystem. Caddy unterstützt Plugins, um zusätzliche Funktionalität in den Web-Server zu integrieren. Manipulieren von HTTP-Headern und Umleiten von URLs ist natürlich Basisfunktionalität. Das inhaltliche Verändern der ausgelieferten Webseiten dagegen ist eine Funktionalität, die man per Plugin nachrüsten muss. Da wir das brauchen, müssen wir einen sogenannten Custom Build anstoßen, damit das Plugin in die Binärdatei integriert wird.

Der obige Downloadlink hat das Plugin bereits vorausgewählt. Ihr müsst nur noch das Zielbetriebssystem auswählen, falls es nicht korrekt erkannt wurde. Dieser Custom Build Modus ist auch der Grund, warum es keinen Sinn macht, Caddy mit einem Package-Manager wie etwa [Homebrew](https://brew.sh/) (Mac) oder [Chocolatey](https://chocolatey.org/) (Windows) zu installieren. Nach dem Download solltet Ihr Caddy in den Suchpfad Eures Betriebssystems einbinden, damit der Aufruf einfacher wird.

Noch ein Hinweis: Caddy versucht einmalig, sein Root-Zertifikat in den Zertifikatspeicher des Betriebssystem einzubinden. Dafür braucht es aber Bibliotheken aus den [Network Security Services (NSS)](https://firefox-source-docs.mozilla.org/security/nss/index.html), einem Mozilla-Projekt (siehe auch [Wikipedia](https://en.wikipedia.org/wiki/Network_Security_Services)). Wenn Caddy diese Bibliotheken nicht finden kann, dann müsste Ihr das Root-Zertifikat von Caddy selber importieren. Ich habe die Bibliotheken auf meinem Mac mit Homebrew installiert (brew install nss) und es klappte automatisch (man wird natürlich nach dem Admin Passwort gefragt für diesen Vorgang). Für Linux kann man den jeweiligen Paket-Manager bemühen. Für Windows gibt es nicht wirklich eine Installationsmöglichkeit. Angeblich soll es reichen, Firefox installiert zu haben, was dann wohl die benötigte nss3.dll mitbringt (habe ich nicht verifiziert, ich arbeite mit Chromium auf einem Mac).

## Konfiguration Caddy

Hier nun der eigentliche Kern des Blogbeitrags, die Konfiguration. Caddy nutzt grundsätzlich ein JSON Format für seine Konfiguration und kann auch zur Laufzeit ohne Neustart per API umkonfiguriert werden (eine weitere Besonderheit). Es gibt aber ein paar Adapter, die auch andere Formate einlesen können, wenn Caddy gestartet wird. Das bekannteste Format is wohl das sogenannte Caddyfile, eine Mischung aus JSON und und einem einfachen Textformat. Das ist für Menschen einfacher zu lesen und schreiben als eine stark hierarchische JSON-Struktur:

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

Die ersten drei Zeilen ordnen das `replace` Plugin in die richtige Prozessreihenfolge ein, damit es funktioniert wie gewünscht (`order replace after encode`, siehe auch das [Plugin auf GitHub](https://github.com/caddyserver/replace-response)).

Danach kommt dann die Konfiguration für unseren lokalen Development Server:

- `localhost:8001`: Wenn Caddy eine Domain erkennt (inklusive localhost), dann wird automatisch für die Domain ein Zertifikat ausgestellt.
- `handle /ords/*`: Startet die Konfiguration für den Pfad `/ords/*`.
- `reverse_proxy http://localhost:7001`: Wir wollen also alle `/ords/*` Anfragen weiterleiten an den ORDS auf Port 7001.

Jetzt kommt der Teil, warum ich eingangs geschrieben habe, dass APEX hinter einem Reverse-Proxy so seine Tücken hat. In eine idealen Welt würde es nicht notwendig sein, Caddy mehr zum Reverseproxy zu sagen, da automatisch die üblichen Header von Caddy gesetzt werden, damit der dahinterliegende Service weiß, dass der Request über einen Proxy-Server gelaufen ist (X-Forwarded-*).

- `header_down Location //localhost/ //localhost:8001/`: header_down meint Richtung Browser, wir ersetzen also alle Location Header, in denen nur `//localhost/` ohne Port steht mit der korrekten Information.
- `header_up Host localhost:8001`: header_up meint Richtung ORDS, wir teilen also ORDS mit, was der Hostname und Port ist (leider versteht das ORDS nicht richtig und ignoriert die Portangabe).
- `header_up +HTTP_X-Forwarded-Port 8001`: Man beachte das kleine Plus-Symbol. Das bedeutet, wir fügen diesen Header hinzu. Ich habe es auch mit `X-Forwarded-Port 8001` versucht, aber ORDS scheint taub auf diesen Ohren zu sein und APEX ist schlau genug, mehrere Portangaben zu berücksichtigen, so dass wenigstens die von APEX generierten URLs korrekt sind.
- `header_up -Origin`: Hier bedeutet das kleine Minus-Sysmbol, dass der Header gelöscht werden soll. Wir tun dies, damit ORDS nicht mit Cross Origin Fehlern austeigt aus dem Spiel. Eigentlich habe ich den ORDS so konfiguriert, dass dies nicht notwendig wäre, aber es hat nicht funktioniert. Wenn jemand eine bessere Lösung hat, dann bitte bei mir melden (siehe hierzu auch die ORDS-Konfiguration weiter unten).
- `replace` und `//localhost/ //localhost:8001/`: Das gleiche Spielchen wie zuvor, nur diesmal nicht mit den Headern, sondern mit dem Inhalt der Anworten (Response Body), die der ORDS aufgrund von REST Aufrufen zurücksendet (meistens JSON Daten). APEX ist hier komplett außen vor.

Jetzt wieder Standard-Funktionalität:

- `handle_path /i/*` (und folgende zwei Zeilen): Hier hosten wir unsere statischen APEX Dateien wie JavaScript, CSS, Bilder, Schriften..., so dass dies nicht vom ORDS übernommen werden muss.
- `redir /ords /ords/`: Hier leiten wir Anforderungen ohne abschließenden Slash um zum korrekten Pfad
- redir `/ /ords/`: Das solltet Ihr individuell anpassen, falls Ihr das Wuzelverzeichnis anders behandeln wollt.

Zur Verteidigung von ORDS muss ich aber sagen, dass man in einer Produktivumgebung mit den Standardports 80 und 443 arbeiten sollte. Damit sind die Probleme hinter einem Proxy deutlich kleiner bzw. verschwinden sogar. Aber das hilft alles nichts, wenn man nicht auf die Standardports zurückgreifen kann. In meinem Fall ist es so, dass der Port abhängig ist davon, in welchem Development Branch ich mich gerade befinde. Ich könnte mehrere Instanzen parallel betreiben, da kann nicht jeder Server auf dem gleichen Port arbeiten wollen...

## Konfiguration ORDS

Hier meine Beispiel-Konfiguration für den ORDS (settings.xml):

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

Die wichtigsten beiden Zeilen im Bezug auf einen Betrieb hinter einem Reverse Proxy:

```xml
<entry key="security.externalSessionTrustedOrigins">localhost:8001</entry>
<entry key="security.httpsHeaderCheck">X-Forwarded-Proto:https</entry>
```

Die erste Zeile sollte eigentlich helfen, so dass wir den Origin Header nicht löschen müssen in Richtung ORDS, es hat aber bei mir nicht funktioniert. Die zweite Zeile hilft ORDS zu erkennen, dass der Frontend-Server (Reverse Proxy) die SSL-Terminierung übernimmt. Für einen Development-Server, wo beide Dienste auf localhost laufen, sehe ich keine Veranlassung, die Verbindung zwischen Proxy und ORDS abzusichern. Das würde gegen mein Ziel gehen, durch Caddy in den Genuss einer vollautomatischen SSL-Lösung zu kommen. Für Prodktivumgebungen sieht das natürlich anders aus. Caddy kann sehr wohl auch Richtung ORDS die Verbindung absichern.

## Caddy starten

Wenn Ihr alles beisammen habt und euer Caddyfile im selben Verzeichnis liegt, wo Ihr auch Caddy startet, dann ist der Startbefehl besonders kurz:

```sh
caddy run
```

Falls die Konfigurationsdatei woanders liegt:

```sh
caddy run --config /path/to/Caddyfile
```

Falls Ihr die Konfigurationsdatei anders nennen wollt, sie aber im Caddyfile Format gespeichert ist:

```sh
caddy run --config /path/to/config.txt --adapter caddyfile
```

Wer mag, kann Caddy (und ORDS) auch als Service in seinem Betriebssystem registrieren, so dass man die Server nicht manuell starten muss.

Ich selber habe mir einen einen kleinen Development-Server mit Node.js gebaut, der zuerst die Konfigurationsdateien für Caddy und ORDS generiert, dann ORDS in der PDB installiert, falls noch nicht geschehen, und danach Caddy und ORDS in jeweils einem Kindprozess startet. Ich kann dann einfach mit Ctrl + C beide gleichzeitig terminieren. Außerdem wird automatisch pro Development Branch ein anderer Port verwendet (daher auch die Ports 7001 und 8001 in meinen Beispielen hier), so dass ich parallel mehrere Instanzen betreiben kann (das klappt gut mit Git Worktrees). Ich arbeite also sehr flexibel auf der Kommandozeile und starte den jeweils benötigten Development Server mit einem kurzen Befehl im jeweiligen Branch bzw. Worktree. Aber das alles wäre dann ein Thema für einen anderen Blogeintrag.

## Fazit

Ich mag es, wenn auch auf meinen Entwicklungsumgebungen SSL-seitig alles gut aussieht. Caddy ist diesbezüglich wirklich eine große Hilfe. Man könnte mit Caddy sogar einen internen Zertifizierungsserver bereitstellen, der dann alle Webserver innerhalb eines Netzwerkes mit Zertifikaten versorgt. Mehr dazu in der [offiziellen Dokumentation](https://caddyserver.com/docs/caddyfile/directives/acme_server).

Vielleicht hilft dieser Blogeintrag ja auch ein paar von Euch da draußen.

Viel Spaß mit dem Caddy Server :-)

Ottmar
