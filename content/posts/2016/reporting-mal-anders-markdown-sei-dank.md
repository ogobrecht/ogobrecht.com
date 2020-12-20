---
title: Reporting mal anders, Markdown sei Dank
description: DOAG Konferenz 2016, Nürnberg
tags: [oracle, apex, doag, slides, markdown, chart]
lang: de
publishdate: 2016-11-17
lastmod: 2017-08-12 20:06:00
---
Die Folien zu meinem Vortrag:

{{< slides "/slides/2016-11-17-reporting-mal-anders-markdown-sei-dank/" >}}

Kurzdarstellung:

_Markdown hat sich in den letzten Jahren als vereinfachte Auszeichnungssprache zur HTML-Erstellung durchgesetzt. Es genügt ein einfacher Texteditor und wenige, allgemein gebräuchliche Konventionen, um z.B. eine Aufzählung in reinem Text auszuzeichnen, die jeder als solche erkennt. Dieser Vortrag erklärt anhand einer Beispiel-Implementierung, wie wir mit Hilfe von Markdown, dem Formatkonverter Pandoc, dem Textsatzsystem LaTeX, der Python Matplotlib und Node.js eine auf Open Source Tools basierende Reporting-Engine erstellen können, die per PL/SQL ansprechbar ist. Das Ergebnis sind hochwertige PDF-Dokumente in Buchdruckqualität, in denen Charts rein vektorbasiert eingebettet sind. Auch bei einer Konvertierung in HTML sind alle Charts vektorbasiert direkt in einer einzelnen HTML-Datei enthalten, wodurch die Weiterverarbeitung erleichtert wird. Was diese Reporting-Engine von anderen unterscheidet ist die Herangehensweise: Es werden keine pixelgenauen Templates erstellt, stattdessen überläßt man es LaTeX, wie der Text gesetzt und die Tabellen und Charts eingebettet werden. Und das ganze eben, ohne sich mit LaTeX-Quellcode auseinandersetzen zu müssen. Zur Auszeichnung wird Markdown verwendet und zur Definition von Tabellen und Charts verwenden wir trickreich die in Markdown vorhandene Möglichkeit, Codeblöcke zu hinterlegen, in die wir einfach unsere SQL-Abfragen eintragen._

Weitere Infos zu dem im Vortrag vorgestellten Projekt [Markdown Reporter auf GitHub][1].

[1]: https://github.com/ogobrecht/markdown-reporter
