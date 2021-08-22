---
title: Show Today Button in APEX Datepicker
description: A short note on how to customize the jQuery UI datepicker
tags: [oracle, apex, jquery]
publishdate: 2018-07-22
lastmod: 2018-07-22 20:00:00
---

Maxime Tremblay has already described [here](http://max-tremblay.blogspot.com/2018/03/datepicker-customization.html) how to customize the datepicker.

He had to deal with missing classes after changing options. I found this week a different way to customize the datepicker without loosing classes added by APEX: Simply by setting datepicker defaults on page load before any datepicker is initialized.

In my case I wanted to enable the button panel which shows two buttons - one to go to the current month which is called `Today` and a second one to close the datepicker which is called `Done` I only wanted the today button, so I had to provide beside the JavaScript or dynamic action some CSS to hide the second one:

```js
apex.jQuery(document).ready(function(){
  $.datepicker.setDefaults({ 'showButtonPanel': true });
});
```

```css
body .ui-datepicker-close { display: none !important; }
```

![jQuery datepicker today button](jquery-datepicker-today-button.png)

Just for reference: The jQuery UI datepicker widget can be tested [here](https://jqueryui.com/datepicker/#buttonbar). Be careful to pick the correct version of the jQuery UI API docs for your specific APEX version.

Happy coding :-)<br>
Ottmar

