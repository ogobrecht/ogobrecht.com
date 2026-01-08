+++
title = "New Major Version of D3 Force Network Chart Available"
date = "2018-12-02"
description = "Better responsiveness by implementing a resize observer"
slug = "new-major-version-of-d3-force-network-chart-available"
aliases = ["/posts/2018-12-02-new-major-version-of-d3-force-network-chart-available/"]

[taxonomies]
tags = ["Oracle", "APEX", "Plug-in", "D3.js", "Chart", "SVG"]

[extra]
giscus = true
+++

![screenshot of a network graph](/img/d3js-force-directed-network.png)

Since APEX version 5 was published with the Universal Theme, I was thinking that I needed something for better responsiveness of the graph. Although it was possible to configure the graph to use the DOM parent width, the responsiveness was not so good because of situations where the window size does not change (we use the window resize event to trigger the change of the width) but the available space for the graph changes. How can the graph react to this?

The problem is that a network chart is not a simple image which can be resized according to the available space. The graph is an SVG with multiple layers to handle the zoom and pan, the lasso, a legend that needs to be in a fixed size...   As you can see, there must be a procedural solution. And for this we need a trigger, which always fires when the (possible) size of the graphs parent DOM element changes.

Fortunately, there is a [W3C draft for a resize observer](https://wicg.github.io/ResizeObserver/) and a [polyfill](https://github.com/que-etc/resize-observer-polyfill) available.

To put the things together, I had to make breaking changes on the API (the reason for a new major version):

I made the API zoom methods independent of the option `zoomMode` and set the default to true for the following options:

- `zoomToFitOnForceEnd` (was false in the past)
- `zoomToFitOnResize` (new option)
- `keepAspectRatioOnResize` (new option)

When setting the option `useDomParentWidth` to true together with the previous mentioned defaults, you can achieve a responsiveness like with images set to width 100%. Try it out by resizing your browser window.

For the full change log see the project on [GitHub](https://github.com/ogobrecht/d3-force-apex-plugin#changelog) and for a demo the app on [apex.oracle.com](https://apex.oracle.com/pls/apex/f?p=18290:1) (which currently does not use the universal theme, new demo app is work in progress...).

Happy networking :-)

Ottmar
