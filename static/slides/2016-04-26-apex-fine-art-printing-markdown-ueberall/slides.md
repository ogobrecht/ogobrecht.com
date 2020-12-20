##  APEX fine art printing, Markdown überall
Ottmar Gobrecht<br>
DOAG APEX Connect 2016, Berlin

-----

## Motivation

---

### Wiki-Fan, Projektanforderungen

- Editor mit Read-Only-Mode
- Harte Zeichenbegrenzung

-----

## Was ist Markdown?

---

### Vereinfachte Auszeichnungssprache

HTML-Erstellung

---

### Ziel: Ohne Konvertierung leicht les- und schreibbar

![Editor Atom mit Live-Vorschau](./assets/editor-atom.png)

---

### HTML = Publikations-Format

### Markdown = Schreib-Format

---

### Einflüsse: Text-Emails, Text-zu-HTML-Konverter

![Beispielmail](./assets/beispielmail.png)

---

### Referenzimplementierung: 2004, John Gruber, Perl

![John Gruber - homepage](./assets/john-gruber.png)

---

### Weitere Implementierungen

- C
- PHP
- Python
- Go
- JavaScript
- Mehr Infos: [Wikipedia Markdown][1]

[1]: https://de.wikipedia.org/wiki/Markdown

---

### Syntax & Weiterentwicklungen

- John Gruber: [Markdown Basics (en)][2]
- John Gruber: [Markdown Syntax (en)][3]
- [Deutsche Übersetzung][4] von Grubers Original
- Wikipedia: [Auszeichnungsbeispiele][5]
- Wikipedia: [Weiterentwicklungen][6]

[2]: https://daringfireball.net/projects/markdown/basics
[3]: https://daringfireball.net/projects/markdown/syntax
[4]: http://markdown.de/syntax/index.html
[5]: https://de.wikipedia.org/wiki/Markdown#Auszeichnungsbeispiele
[6]: https://de.wikipedia.org/wiki/Markdown#Weiterentwicklungen

---

### Weitere vereinfachte Auszeichnungssprachen

- Wikis: [MediaWiki][7], [DokuWiki][8], [Creole][9]
- Foren: Quasistandard [BBCode][10]
- [Emacs][11] Erweiterung [Org-mode][12]
- Quellcode-Doku mit [POD][13] oder [Javadoc][14]
- [Textile][15], [AsciiDoc][16], [reStructuredText][17]
- ...

[7]: https://de.wikipedia.org/wiki/MediaWiki
[8]: https://www.dokuwiki.org/
[9]: https://de.wikipedia.org/wiki/Creole_(Markup)
[10]: https://de.wikipedia.org/wiki/BBCode
[11]: https://de.wikipedia.org/wiki/Emacs
[12]: https://de.wikipedia.org/wiki/Org-mode
[13]: https://de.wikipedia.org/wiki/Plain_Old_Documentation
[14]: https://de.wikipedia.org/wiki/Javadoc
[15]: https://de.wikipedia.org/wiki/Textile
[16]: https://de.wikipedia.org/wiki/AsciiDoc
[17]: https://de.wikipedia.org/wiki/ReStructuredText

---

### Fragen?

-----

## Wer nutzt Markdown?

---

### Github: README.md Dateien werden direkt als HTML ausgeliefert

![GitHub README Dateien](./assets/github-readme.png) <!-- .element: width="800px" -->

---

### Stackoverflow: Alle Einträge/Kommentare sind in Markdown verfasst

![Stackoverflow](./assets/stackoverflow.png)

---

### Verlage & Autoren, die sowohl eBooks als auch klassischen Druck benötigen

Ein paar interessante Blog-Einträge zum Thema:

- Michael Kofler:
  - [Sackgasse LaTeX?][18]
  - [Kindle-eBooks mit Pandoc erstellen][19]
- Open Source Press:
  - [Bye-bye LaTeX!][20]
  - [AsciiDoc, Markdown & Co.][21]

[18]: https://kofler.info/sackgasse-latex/
[19]: https://kofler.info/kindle-ebooks-mit-pandoc-erstellen/
[20]: http://www.opensourcepress.de/de/blog/2013/05/bye_bye_latex.php
[21]: http://www.opensourcepress.de/de/blog/2013/05/asciidoc_markdown.php

---

### Die DPA veröffentlicht ihre Pressemitteilungen seit 2010 in Markdown

---

### Der Listmanager Trello nutzt Markdown auf Kartendetails

![Trello](./assets/trello.png) <!-- .element: width="800px" -->

---

### Die Blogging Plattform Ghost setzt zu 100% auf Markdown

![Ghost](./assets/ghost.png) <!-- .element: width="800px" -->

---

### Plugins für jedes wichtige CMS, Wiki oder Forum - auch für APEX [:-)][22]

![APEX plugin](./assets/apex-plugin.png) <!-- .element: width="800px" -->

[22]: https://apex.oracle.com/pls/apex/f?p=66154:1

---

### Jeder intuitiv, der einfachen Text strukturiert

---

### Fragen?

-----

## Gründe für Markdown im APEX-Umfeld

---

### Rohtext gut lesbar in Datenbank und Userinterface

---

### Einfach prozedural erstellbar

---

### Textmengenvorgaben gut einhaltbar

![Textmenge](./assets/textmenge.png)

---

### Geringere Datenmenge zum Browser

![Textmenge 2](./assets/textmenge2.png)

---

### Ein Quelltext, viele Ausgabeformate

Beispiel Formatkonverter [Pandoc][23]:

- HTML
- Word(docx), OpenOffice (odt)
- PDF
- E-Books (epub)
- Slideshows (HTML5 oder LaTeX)
- ...

[23]: http://pandoc.org/

---

### Übrigens, dieser Vortrag wurde in Markdown verfasst [:-)][24]

![Vortrag in Markdown](./assets/vortrag.png)

[24]: http://pandoc.org/README.html#producing-slide-shows-with-pandoc

---

### APEX Markdown Plugin in Action

[Demo...][25]

[25]: https://apex.oracle.com/pls/apex/f?p=66154:1

-----

## APEX fine art printing

---

### Die Idee

- Markdown als Eingabeformat
- [Pandoc][26] als Konverter nach HTML, DOCX, PDF, ...
- [Node.js][27] als Web-Schnittstelle zu Pandoc
- Mehr zu [Pandocs Markdown][28]

[26]: http://pandoc.org/
[27]: https://nodejs.org/
[28]: http://pandoc.org/README.html#pandocs-markdown

---

### Fine art printing?

- Pandoc nutzt [LaTeX][29] zur PDF-Erstellung:
  - Textsatzsystem
  - Sauberes Schriftbild
  - Guter Formelsatz
  - Standard im Publikationsumfeld (Verlage, wissenschaftliche Arbeiten)

[29]: https://de.wikipedia.org/wiki/LaTeX

---

### Fine art printing in Action

Demo und Diskussion...

-----

## Bonustrack

---

### Die Idee

- Markdown kennt Codeblöcke
- Codeblöcke können SQL Statements sein
- SQL Statements kann eine Datenbank ausführen
- Wer ahnt es schon?

---

### Eine Reporting-Engine basierend auf Markdown

- SQL-Code-Blöcke werden speziell markiert
- Hilfsfunktion ersetzt Blöcke durch Daten
- Ein [Pandoc-Filter][30] wandelt Daten in Charts
- Chart-Engine: Python [matplotlib][31], [pandas][32]
- Alles vektorbasiert und Open Source

[30]: http://pandoc.org/scripting.html
[31]: http://matplotlib.org/
[32]: http://pandas.pydata.org/index.html

---

### Was jetzt noch fehlt

- ~~Ein PL/SQL Package zur Wandlung der Code-Blöcke~~
- ~~Ein Pandoc-Filter~~
- ~~Eventuell eine Oberfläche zur Erstellung der Reports~~

---

### Markdown Reporter in Action (Prototyp)

Demo und Diskussion...

---

## The End

### Fragen?

[ogobrecht.github.io][33]

[33]: https://ogobrecht.github.io
