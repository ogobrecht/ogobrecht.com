+++
title = "Double click on APEX report row opens first link target"
date = "2015-01-14"
description = "A page zero dynamic action for your whole application"
slug = "double-click-on-apex-report-row-opens-first-link-target"
aliases = ["/posts/2015-01-14-double-click-on-apex-report-row-opens-first-link-target/"]

[taxonomies]
tags = ["Oracle", "apex"]
+++

_Do you like scanning a report for certain information and then moving the mouse to the first column to click the small link for details or a edit form? Would it be nice to double click anywhere on the row to open the first link?_

With a little help of a dynamic action on page zero you have the solution for all your interactive and standard reports in your application. The only additional to do is, to find out the right selectors for your reports. Here some usual ones:

```js
//APEX 5:
table.a-IRR-table tr, table.uReportStandard tr

//APEX 4:
table.apexir_WORKSHEET_DATA tr, table.uReportStandard tr
```

I give you no guarantee that this will also work with your theme. Please ask your browsers developer tools and inspect your report layouts ;-)

Create a dynamic action for a double click on a jQuery selector (see examples above) and set the event scope to dynamic.

The dynamic action needs to execute JavaScript:

```js
$(this.triggeringElement).find('td:first>a')[0].click();
```

Happy coding :-)

Ottmar
