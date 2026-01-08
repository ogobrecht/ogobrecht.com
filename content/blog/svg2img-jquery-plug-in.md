+++
title = "jQuery Plugin svg2img"
date = "2017-04-03"
description = "Convert inline SVGs to standalone image files without loosing styles"
slug = "jquery-plugin-svg2img"
aliases = ["/posts/2017-04-03-jquery-plugin-svg2img/"]

[taxonomies]
tags = ["jQuery", "Plug-in", "SVG"]

[extra]
giscus = true
+++

SVG based charts and visualizations are often used these days. But what if you want to use your browser inline SVGs, generated with some sort of JavaScript and fancy styled with CSS, offline - maybe in a presentation, send by email or printed out large scaled?

You can create a screenshot, of course. But does this look nice when it comes to scaling? You can try to copy the HTML code of the SVG and wrap it into a correct SVG container, but then you will loose in the most cases the stylings, as normally not all CSS definitions are directly attached to the SVG elements. You can also use a browser extension like [this one for Google Chrome](https://chrome.google.com/webstore/detail/export-svg-with-style/dkjdcaddoplepioppogpckelchefhddi), but then you depend on the browser and the extension.

There is now a declarative way with the help of a jQuery plugin, which is 100% client based:

```js
jQuery('#example-graph').svg2img();
```

There is one default option - you can redeclare it:

```js
jQuery.fn.svg2img.defaults = {
    debug: false // write debug information to console
};
```

You can also set the debug option at runtime:

```js
$('#example-graph').svg2img({debug:true});
```

The plugin checks if your selector is a SVG element. If this is not the case, it searches under each selector element for all SVGs and exports it. The name(s) of the file(s) are automatically derived from the element ID (or parent element ID) or set to `export`. The current date and time is appended to the file name, for example `example-graph-20170403-154653.svg`.

You can download all SVGs from one page by setting the selector to the document, body or svg - as you like it. There is no need for a `each()` call, `svg2img` works on the whole selection and is chainable:

```js
$("svg").svg2img().css("border", "1px solid red");
```

If you want to use anchors to provide export links then it is recommended to prevent the default action like so:

```html
<a href="" onclick="event.preventDefault(); $('#example-graph').svg2img();">SVG</a>
```

Otherwise Firefox and IE failing to save. One last thing: Safari has currently (as of this writing) problems with the underlaying `savAs()` implementation and tries to open the images in a new tab with or without success. See also this [issue on GitHub](https://github.com/eligrey/FileSaver.js/issues/267).

UPDATE 2017-04-14: After update to macOS Sierra 10.12.4 Safari 10.1 works also - but is as slow as before - collecting CSS styles runs on my MacBook 2800ms in Safari, 20ms in Google Chrome :-(
I stopped to support other image formats then SVG since the canvas export behind the scenes was not really working in too many browsers and the core feature was and is to convert inline SVGs to standalone SVG images.

The project is hosted on [GitHub](https://github.com/ogobrecht/jquery-plugin-svg2img) and MIT licensed.

Happy SVG exporting :-)

Ottmar
