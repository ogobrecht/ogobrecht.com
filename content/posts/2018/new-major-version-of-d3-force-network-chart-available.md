---
title: New Major Version of D3 Force Network Chart Available
description: Better responsiveness by implementing a resize observer
tags: [oracle, apex, plugin, d3js, chart, svg]
lang: en
publishdate: 2018-12-02
lastmod: 2018-12-05 20:00:00
---

<div id="example"></div><!--the graph container-->

Since APEX version 5 was published with the Universal Theme, I was thinking that I needed something for better responsiveness of the graph. Although it was possible to configure the graph to use the DOM parent width, the responsiveness was not so good because of situations where the window size does not change (we use the window resize event to trigger the change of the width) but the available space for the graph changes. How can the graph react to this?

The problem is that a network chart is not a simple image which can be resized according to the available space. The graph is an SVG with multiple layers to handle the zoom and pan, the lasso, a legend that needs to be in a fixed size...   As you can see, there must be a procedural solution. And for this we need a trigger, which always fires when the (possible) size of the graphs parent DOM element changes.

Fortunately, there is a [W3C draft for a resize observer][1] and a [polyfill][2] available.

To put the things together, I had to make breaking changes on the API (the reason for a new major version): 

I made the API zoom methods independent of the option `zoomMode` and set the default to true for the following options:

- `zoomToFitOnForceEnd` (was false in the past)
- `zoomToFitOnResize` (new option)
- `keepAspectRatioOnResize` (new option)

When setting the option `useDomParentWidth` to true together with the previous mentioned defaults, you can achieve a responsiveness like with images set to width 100%. Try it out by resizing your browser window.

For the full change log see the project on [GitHub][3] and for a demo the app on [apex.oracle.com][4] (which currently does not use the universal theme, new demo app is work in progress...).

Happy networking :-)<br>
Ottmar


[1]: https://wicg.github.io/ResizeObserver/
[2]: https://github.com/que-etc/resize-observer-polyfill
[3]: https://github.com/ogobrecht/d3-force-apex-plugin#changelog
[4]: https://apex.oracle.com/pls/apex/f?p=18290:1

<link  href="/assets/d3.js/d3-force-3.0.0.css" rel="stylesheet" type="text/css">
<script src="/assets/d3.js/ResizeObserver-1.5.0.min.js"></script>
<script src="/assets/d3.js/d3-3.5.6.min.js"></script>
<script src="/assets/d3.js/d3-force-3.0.0.min.js"></script>

<style>.net_gobrechts_d3_force_tooltip { z-index: auto; }</style>

<script>
window.onload = function() {
    window.example = netGobrechtsD3Force('example')
        .height(400)
        .width(800)
        .useDomParentWidth(true) //for responsive layout
        //.zoomMode(true)
        .lassoMode(true)
        .wrapLabels(true)
        .showBorder(false)
        .debug(true) //to enable the customization wizard
        .render(); //sample data is provided when called without data
        //see also https://ogobrecht.github.io/d3-force-apex-plugin/tutorial-1-getting-started.html
    d3.select('#example').select('svg').classed('shadow', true);
}
</script>
