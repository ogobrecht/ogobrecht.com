---
title: Form Behaviour - Bug or Feature?
description: Why forms with a single input field are submitted by the enter key
tags: [apex, html]
slug: why-forms-with-single-input-are-submitted-by-the-enter-key
publishdate: 2017-09-26
lastmod: 2017-10-01 20:00:00
---

Today I stumbled over this strange behaviour of an APEX page: The page was always submitted when I pressed the enter key in a search field to force an AJAX refresh on a report.

The item property to submit the page on pressing enter was switched off. I asked my collegue Markus, who had this error also some time ago (I could not remember the solution, although he told me about this issue). The reason was that the search field was the only input item on that page.

After a short Google search I found the "root cause" for this "bug", or should I say "feature"? This behaviour is described in the [HTML 2.0 specification (section 8.2)][2].

To workaround this you can simply create a second input item and hide it by setting the "HTML Form Element Attributes" to `style="display:none;"`. This was also posted by [Denes Kubicek][3] back in 2008.

I like the idea of one of the [Stack Overflow comments][1] to put anywhere into the form (in APEX in fact the whole page, e.g. the header or footer of a region) this HTML snippet and not to create an "useless" page item:

```html
<input type="text" name="StackOverflow1370021" style="display:none;" />
```

It is worth to mention that I run the newest Chrome browser and this "feature" is still available...

Happy coding :-)

Ottmar

[1]: https://stackoverflow.com/questions/1370021/why-does-forms-with-single-input-field-submit-upon-pressing-enter-key-in-input
[2]: http://www.w3.org/MarkUp/html-spec/html-spec_8.html#SEC8.2
[3]: http://deneskubicek.blogspot.de/2008/06/textfield-item-submiting-page.html
