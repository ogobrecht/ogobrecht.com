+++
title = "Markdown Reporter"
date = "2017-01-23"
description = "Write your reports with Markdown, get HTML or LaTeX PDFs"
slug = "markdown-reporter"
aliases = ["/posts/2017-01-23-markdown-reporter/"]

[taxonomies]
tags = ["Oracle", "PL/SQL", "Node.js", "Pandoc", "Python", "Matplotlib"]

[extra]
giscus = true
+++

On the APEX connect 2016 in Berlin I talked about my APEX Markdown plugin and fine art printing with the help of Pandoc and LaTeX. When I was preparing my slides and documenting a SQL query in a Markdown code block I asked myself:

What, if the database is taking this Markdown code block and runs the query inside to convert it into data?

And what, if I take this Markdown text with the data in the code blocks and post it to a small webservice which converts the data blocks into charts and the whole document into HTML or a LaTeX based PDF?

The idea to Markdown Reporter was born.

I talked about this project on the DOAG conference in Nuremberg last November. Here are the [slides](/slides/2016-11-17-reporting-mal-anders-markdown-sei-dank/) (in german, sorry).

If you want to know how it looks like - here is a [PDF demo report](/slides/2016-11-17-reporting-mal-anders-markdown-sei-dank/assets/demo-report.pdf)

The implementation has three main components:

- An Oracle PL/SQL Package for preprocessing your data and communicating with the printserver
- A Node.js based printserver, which is in fact a web based remote shell for the format converter [Pandoc](http://pandoc.org/)
- A Pandoc filter written in Python, which intercepts the converting process and generates the charts based on the preprocessed CSV data with the help of Pythons [matplotlib](http://matplotlib.org/)

The HTML and PDF output is complete vector based and all used tools are open source.

You can find the sources and more informations on [GitHub](https://github.com/ogobrecht/markdown-reporter).

Happy reporting :-)

Ottmar
