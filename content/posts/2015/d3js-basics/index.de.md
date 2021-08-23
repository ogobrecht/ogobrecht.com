---
title: D3.js Grundlagen
description: DOAG/SOUG News 02-2015
tags: [oracle, apex, doag, d3js, svg]
slug: d3js-grundlagen
aliases: [/posts/2015-03-01-d3js-grundlagen/]
publishdate: 2015-03-01
lastmod: 2019-08-15 21:00:00
---

{{< toc "Inhaltsverzeichnis" >}}


## Einleitung

Dieser Artikel erschien im Magazin DOAG/SOUG News 02-2015 und steht auch im [Original][doag] zur Verfügung. Im Gegensatz zu der Papierversion der DOAG haben wir natürlich auf einer Webseite alle Möglichkeiten, D3 live zu zeigen - also los, wir starten mit einer Netzwerkvisualisierung live im Browser (JavaScript muß aktiv sein, damit die Beispiele auf dieser Seite funktionieren):

[doag]: https://mydoag.doag.org/formes/pubfiles/6900184/docs/Publikationen/DOAGNews/2015/02-2015/2015-02-News-Ottmar-Gobrecht-D3-Data-Driven-Documents.pdf

<figure>
  <div id="v0"></div><!--the graph container-->
<figcaption>Knoten dürfen bewegt werden ;-)</figcaption>
</figure>

*D3 ist eine JavaScript Bibliothek zum Manipulieren von HTML Dokumenten auf der Basis von Daten und setzt dabei auf die Webstandards HTML, SVG und CSS. Dieser Artikel zeigt die Grundlagen von D3 und weckt das Interesse am Thema "Datenvisualisierung mit Webstandards". Vorab nur soviel: Auch D3 kennt den Begriff des Joins.*


## Beispiele von der D3 Homepage

![Beispiel von github.com/mbostock/d3/wiki/Gallery](/slides/2015-06-09-d3js-data-driven-documents/assets/beispiel-9.png)

![Beispiel von github.com/mbostock/d3/wiki/Gallery](/slides/2015-06-09-d3js-data-driven-documents/assets/beispiel-10.png)


## D3: Was ist das?

D3 steht für DDD = Data Driven Documents. Neben den oben gezeigten Beispielen kennt D3 alle üblichen Charts und beim Anblick der Startseite unter [d3js.org][d3] wird einem klar, daß es wohl keine Grenzen bei der Umsetzung zu geben scheint. Hier der unvollständige Versuch, D3 etwas genauer zu definieren:

[d3]: http://d3js.org

1. D3 ist eine JavaScript-Entwicklerbibliothek, welche es erlaubt, Daten mit grafischen Elementen (SVG) im Browser zu kombinieren und diese so auf vielfältige Art und Weise zu visualisieren
2. Durch seinen Data Join Ansatz (Aufklärung folgt später) ist D3 im Verhältnis zu anderen Bibliotheken auch bei großen Datenmengen sehr schnell
3. Aufgrund der Unterstützung von Webstandards ist D3 zukunftssicher und auch auf mobilen Geräten lauffähig
5. D3 basiert auf HTML5 und CSS3, es benötigt also einen modernen Browser (Firefox, Chrome, Safari, IE9 aufwärts)
4. D3 ist KEINE Chart-Engine, bei der man fertige Layouts auswählt und konfiguriert


## Das Fundament: SVG

SVG steht für Scalable Vector Graphics und basiert auf XML. Die zweidimensionalen SVG Zeichnungselemente haben gegenüber Raster-Grafiken den Vorteil, verlustfrei skaliert werden zu können. Ihnen fehlt also der berühmte Treppenstufeneffekt, der bei extremer Vergrößerung bei Rasterformaten auftritt. SVG im Browser wurde im Rahmen von HTML5 standardisiert.

Im Gegensatz zu HTML-Elementen, die im Grunde nur die Rechteckform kennen, gibt es bei SVG-Elementen Pfade und zur einfacheren Handhabung alle grafischen Grundformen wie Kreis, Ellipse, Rechteck, Linie und Polygon. Zusätzlich kann man noch Text und externe Rastergrafiken verwenden. Alle genannten Elemente können durch das Gruppenelement zusammengefasst werden.

Elemente und Gruppen von Elementen können über Style Attribute in Ihrer Erscheinung angepasst und über Transformationen in Position, Orientierung und Form verändert werden. An Transformationen stehen Parallelverschiebung, Rotation, Skalierung und Scherung zur Verfügung, die über CSS3 Transitions auch über einen vorgegebenen Zeitraum hinweg verändert werden können. Daneben gibt es noch Animationen sowie grafische Effekte und Filter. Wer sich tiefergehender dafür interessiert, findet im Web eine Menge Informationen und Beispiele.

Man kann SVG Grafiken auf mehreren Wegen in HTML einbinden: Als externe Grafik oder direkt im HTML mit dem Tag `<svg>`. Bei einer externen Grafik muß wie bei XML der Namespace definiert werden. Bei direkter Einbindung in HTML braucht man das nicht; was im Zusammenhang mit D3 den Standardfall darstellt. Bis auf die ungewohnten Tag- und Attributnamen wird einem also nicht viel auffallen, wenn man sich eine HTML-Seite mit eingebettetem SVG im DOM Inspector eines modernen Browsers anschaut. Insofern ist SVG recht pflegeleicht und man kann die gewohnten Werkzeuge des Browsers nutzen.

Wer jQuery kennt, wird sich schnell in D3 zurechtfinden. D3 unterstützt auch die Methodenverkettung und die Basismethoden wie `append` und `attr` haben die gleichen Namen oder zumindest ähnliche wie z.B. `style` bei D3 und `css` bei jQuery. Listing 1 zeigt ein Beispiel, drei SVG Elemente direkt in HTML und ein Element prozedural mit D3.


{{< figure "Listing 1: Ein einfaches SVG Beispiel" >}}
```html
<!DOCTYPE html><html><head><title>SVG Beispiel</title></head><body>
<script src="http://d3js.org/d3.v3.min.js"></script>

<svg id="v1" viewBox="0 0 450 120" style="width:600px; max-width:100%;">
  <rect x="0" y="0" height="120" width="160" fill="#ff6600"/>
  <ellipse cx="240" cy="60" rx="120" ry="40" fill="green"/>
  <line x1="20" y1="20" x2="450" y2="100" stroke="blue"/>
</svg>

<script>
  d3.select('svg#v1').append('circle')
    .attr('cx','380')
    .attr('cy','60')
    .attr('r','55')
    .style('stroke','red')
    .style('fill','lightsteelblue')
    .style('fill-opacity',0.5);
</script>

</script></body></html>
```
{{< /figure >}} 


<figure>
<svg class="shadow" id="v1" viewBox="0 0 450 120" style="width:600px; max-width:100%;">
  <rect x="0" y="0" height="120" width="160" fill="#ff6600"/>
  <ellipse cx="240" cy="60" rx="120" ry="40" fill="green"/>
  <line x1="20" y1="20" x2="450" y2="100" stroke="blue"/>
</svg>
<figcaption>Abbildung 1: Das Ergebnis aus Listing 1</figcaption>
</figure>


Wie man in Listing 1 erkennen kann, heißt bei SVG das Attribut für die Füllfarbe `fill` und das für die Konturfarbe `stroke`. Der Bezugspunkt für das Positionieren von Elementen ist die linke obere Ecke des SVG Elementes. Das gilt auch beim Rechteck-Element. Beim Kreis und der Ellipse ist der Bezugspunkt hingegen die Mitte. Da wir hier live im Browser arbeiten: Einfach mal die Konsole öffnen und mit einer veränderten Version des Skriptes herumprobieren ;-)


## Der Unterschied: Selectors versus Selections

In JavaScript kann mit den aus CSS bekannten Selektoren Elemente im DOM auswählen. Möchte man dann Änderungen an den Elementen vornehmen, muß man mit einer Schleife über alle Elemente iterieren. D3 verfolgt einen anderen Ansatz, wie man schon an der Bezeichnung erkennen kann - hier wird von [Selections][select] gesprochen. Jede Selection ist ein Array, auch wenn es nur ein oder gar kein Element enthält. Wenn man das Array dann mit einer Methode aufruft, iteriert D3, wie übrigens jQuery auch, automatisch über alle Elemente. Listing 2 zeigt den Vergleich:

[select]: http://bost.ocks.org/mike/selection/


{{< figure "Listing 2: JavaScript versus D3" >}}
```js
// Schleife über alle Elemente: JavaScript
var p = document.getElementsByTagName('p');
for (var i = 0; i < p.length; i++) {
  var pi = p.item(i);
  pi.style.setProperty('color','red', null);
}

// Schleife über alle Elemente: D3
d3.selectAll('p').style('color','red');
```
{{< /figure >}}


## Die D3 Mengenlehre: Wie man Daten an das DOM bindet

Bevor man Daten an das DOM binden kann, müssen diese erst einmal zur Verfügung stehen. D3 stellt für das Lesen von Daten XHR (XMLHttpRequest) Methoden zur Verfügung. Damit können Daten per JavaScript nachgeladen werden. Der Vorteil dieses Vorgehens ist, dass sich das Laden der eigentlichen Webseite bei großen Datenmengen nicht verzögert. Zur einfacheren Handhabung gibt es darauf aufbauend vier Wrappermethoden, die für das Laden von CSV, TSV, XML und JSON Daten genutzt werden können. Häufig kommt es aber auch vor, daß man diese auch AJAX Calls genannten Aufrufe mit den Methoden des jeweils benutzten Entwicklungs-Frameworks macht, wobei sich das Datenformat JSON durchgesetzt hat. Bei APEX gibt es zum Beispiel fertige Methoden in den mitgelieferten JavaScript Bibliotheken und bei kleineren Datenmengen mag es auch ok sein, diese direkt in die Seite zu rendern. Wege gibt es viele. Am Ende benötigt man JavaScript Arrays, die die Daten enthalten und über die D3 iterieren kann. Wie die "Zeilen" bzw. Objekte des Arrays aussehen, hängt stark vom Anwendungsfall ab.

<figure>
<svg class="shadow" viewBox="0 0 380 160" style="width:500px; max-width:100%; text-anchor: middle;">
  <ellipse cx="130" cy="90" rx="120" ry="60" fill="orange" fill-opacity="0.5"/>
  <ellipse cx="250" cy="90" rx="120" ry="60" fill="steelblue" fill-opacity="0.5"/>
  <text x="130" y="25">Data</text>
  <text x="250" y="25">Elements</text>
  <text x="75" y="98">Enter</text>
  <text x="190" y="98">Update</text>
  <text x="305" y="98">Exit</text>
</svg>
<figcaption>Abbildung 2: Der D3 Data Join (weiteres Beispiel auf d3js.org: <a href="http://bost.ocks.org/mike/join/">Thinking with Joins</a>)</figcaption>
</figure>

Nun zur eigentlichen Frage: D3 bindet Daten an das DOM, in dem man einer Selection über den Data Operator die Daten in Form eines Arrays übergibt. Hier kommt der Eingangs erwähnte Data Join zum Einsatz. Zurückgeliefert werden drei neue Selections, die D3 Update, Enter und Exit nennt. Abbildung 2 zeigt schematisch die Zusammenhänge. In der Update Selection sind die Elemente des DOM mit den Elementen des Data Arrays in der Reihenfolge ihres jeweiligen Erscheinens verknüpft. Wie man unschwer errät, kann aber eine unterschiedliche Anzahl an Elementen im DOM und in den Daten vorhanden sein. Wenn im DOM mehr Elemente vorhanden sind als Daten, dann liegen diese Elemente in der Exit Selection, mit der man die Elemente aus dem DOM entfernen kann. Gibt es mehr Daten als DOM Elemente, dann befinden sich diese Daten in der Enter Selection, mit der die fehlenden Elemente im DOM erstellt werden können. Listing 3 zeigt ein Beispiel und darauf folgt das Live-Ergebnis - wer möchte, kann in der Browserkonsole damit ein wenig herumspielen.

{{< figure "Listing 3: Data Join (weiteres Beispiel auf d3js.org: [Three Little Circles](http://bost.ocks.org/mike/circles/))" >}}
```html
<!DOCTYPE html><html><head><title>Data Join</title></head><body>
<script src="http://d3js.org/d3.v3.min.js"></script>

<div id="v3">
  <p style="color:green;">Ein bereits existierendes Element</p>
</div>

<script>

  var v3 = {};
  v3.div = d3.select('div#v3');

  //Die Update-Selection: Der vorhandene Paragraph wird aktualisiert
  v3.p = v3.div.selectAll('p').data([1,2,3])
    .style('color', 'red');

  //Die Enter-Selection: Hier kommen zwei neue Paragraphen hinzu
  v3.p.enter().append('p')
    .text( function(d){return 'Neues Element aus Daten ' + d;} );

  //Die Exit-Selection ist in unserem Beispiel leer
  v3.p.exit().remove();

</script></body></html>
```
{{< /figure >}}

<figure>
<div id="v3" class="shadow" style="padding:10px; display:inline-block;">
  <p style="color:green;">Ein bereits existierendes Element</p>
</div>
<figcaption>Abbildung 3: Das Ergebnis aus Listing 3</figcaption>
</figure>

Wie man in Listing 3 sieht, steht einem die Update Selection sofort in der Methodenverkettung zur Verfügung und sie hat keinen eigenen Namen. Es wäre aber auch möglich, die Enter oder Exit Selection zuerst aufzurufen. Wichtig ist, zu wissen, dass nach Abarbeitung der ersten Selection die anderen Selections gesondert aufgerufen werden müssen - eine weitere Verkettung ist nicht möglich. Außerdem stehen einem die Elemente der Enter Selection nach Ausführung in der Update Selection zur Verfügung. Man könnte also z.B. erst die neuen Elemente anlegen ohne weitere Attribute oder Styles zu definieren und dann mit einem Aufruf der Update-Selection alle Elemente auf einmal aktualisieren (in Listing 4 passiert das so in dieser Reihenfolge).

Für den Fall, das der einfache Data Join über die Reihenfolge der Elemente in DOM und Array nicht genügt, gibt es eine sogenannte Key Function, anhand derer die Elemente im DOM identifiziert werden. Die anonyme Funktion wird bei Bedarf als zweiter Parameter dem Data Operator übergeben. Listing 4 zeigt ein Beispiel einer Data Key Funktion - hier wird zur Identifikation die ID verwendet. Wer wissen möchte, wie das alles ganz genau funktioniert, der findet das [hier][6] durch den Autor von D3 sehr ausführlich erklärt.

[6]: http://bost.ocks.org/mike/selection/

{{< figure "Listing 4: Data Key Function" >}}
```html
<!DOCTYPE html><html><head><title>Data Key Function</title></head><body>
<svg id="v4" viewBox="0 0 200 30" style="width:500px; max-width:100%;"></svg>
<script src="http://d3js.org/d3.v3.min.js"></script><script>

  var v4 = {};
  v4.data = [
    {"id":1, "r":14, "x":50,  "y":15, "color":"red"},
    {"id":2, "r":14, "x":70, "y":15, "color":"green"},
    {"id":3, "r":14, "x":90, "y":15, "color":"blue"}
  ];

  v4.svg = d3.select('svg#v4');

  v4.circles = v4.svg.selectAll('circle')
    //hier wird die key function verwendet
    .data(v4.data, function(d){return d.id;});

  //Wir rufen zuerst die Exit-Selection auf
  v4.circles.exit().remove();

  //Dann fügen wir über die Enter-Selection die neuen Elemente ein
  v4.circles.enter().append('circle');

  //Zuletzt aktualisieren wir alle Elemente mit der Update-Selection
  v4.circles
    .attr('r',    function(d) { return d.r; })
    .attr('cx',   function(d) { return d.x; })
    .attr('cy',   function(d) { return d.y; })
    .attr('fill', function(d) { return d.color; });

</script></body></html>
```
{{< /figure >}}

<figure>
<svg id="v4" class="shadow" viewBox="0 0 200 30" style="width:500px;"></svg>
<figcaption>Abbildung 4: Das Ergebnis aus Listing 4</figcaption>
</figure>

Was wird eigentlich passieren, wenn man folgenden Code ausführt? Wer mag, kann das einfach mal in der Browserkonsole ausprobieren (Mehr zu [Transitions][7]):

[7]: https://bost.ocks.org/mike/transition/

```js
v4.data = [
  {"id":1, "r":7,  "x":30,  "y":15, "color":"blue"},
  {"id":3, "r":14, "x":120, "y":15, "color":"red"},
  {"id":4, "r":10, "x":75, "y":15, "color":"orange"}
];
v4.circles = v4.svg.selectAll('circle')
  .data(v4.data, function(d){return d.id;});
v4.circles.exit().remove();
v4.circles.enter().append('circle');
v4.circles.transition()
  .attr('r',    function(d) { return d.r; })
  .attr('cx',   function(d) { return d.x; })
  .attr('cy',   function(d) { return d.y; })
  .attr('fill', function(d) { return d.color; });
```

## Das Geheimnis der Geschwindigkeit

Die Konsequenz aus dem Vorgehen von D3 ist, dass man immer erst eine Selection erstellt, auch wenn man weiß, das im DOM keine Elemente vorhanden sind. An die Selection werden die Daten gebunden und im Falle einer statischen Visualisierung reicht es dann aus, über die Enter Selection die DOM Elemente zu erstellen. Im Falle von dynamischen Visualisierungen spielt dieses Vorgehen sein Stärken aus. Ändern sich nicht alle Daten, muß D3 nur die neuen Elemente im DOM anlegen, alte entfernen, und vorhandene können aktualisiert werden. Dies spart Resourcen im Browser, da nur die nötigste Arbeit zu tun ist, anstatt alle Elemente aus dem DOM zu entfernen, um sie dann wieder neu anzulegen. Außerdem speichert sich D3 in den Selections die Referenzen auf die DOM-Elemente, dadurch muß für weitere Updates des DOM keine weitere Elementsuche auf dem DOM ausgeführt werden. Nun ist es gelüftet, das Geheimnis hinter der Geschwindigkeit - D3 verhindert ganz einfach unnötige Arbeit für den Browser, womit Rechenkapazität für das Bearbeiten größerer Datenmengen frei wird.


## Wiederverwendung von Chart Code

Der Schwerpunkt von D3 liegt nicht auf dem Ausliefern von fertigen Chartfunktionen, in die man einfach seine Daten kippt. D3 konzentriert sich auf grundlegende, immer wieder benötigte Dinge und bietet dafür generisch verwendbare Hilfsfunktionen an. Man muss zwar Arbeit in seine Charts stecken, hat aber durch den generischen Ansatz der Basisfunktionen praktisch keine Einschränkungen bei der Umsetzung, wie man an den vielen Beispielen im Internet sehen kann.

Man kommt am Anfang mit diesen Beispielen schnell zu ansehnlichen Ergebnissen. Spätestens wenn man mit dem gleichen Code einen zweiten Chart auf der selben HTML-Seite einbauen möchte, sieht man jedoch die Grenzen: Globale Variablen und Funktionen sind schnell redeklariert und ein zweiter Chart stört die Funktion des ersten. Hier ist es dann an der Zeit, über Kapselung und Wiederverwendung von Chart-Code zu sprechen. Dazu muß man wissen, wie JavaScript mit Variablen und Funktionen umgeht. Das Stichwort hier sind Closures.


## Exkurs: Closures in JavaScript

In JavaScript ist alles ein Objekt und Funktionen können Objekte, also auch Funktionen, zurückgeben.

Eine Closure ist am Ende nichts anderes als ein Funktionsaufruf, bei dem eine Funktion zurückgegeben wird. Die zurückgegebene Funktion behält Ihren vorherigen Kontext, kann also auf die vor der Rückgabe vorhandenen Variablen innerhalb ihrer Ursprungsfunktion zugreifen. Sie kapselt quasi Ihre Umhebung, daher der Name. Die Folge eines solchen Vorgehens ist, dass man dadurch private Variablen erhält, die von außen nicht einsehbar sind. Um trotzdem an diese Variablen zu kommen, muß man dann entsprechende Get- und Set-Funktionen definieren.

Listing 5 zeigt die Prinzipien. Abbildung 5 zeigt das Ergebnis aus Listing 5 und kann einfach in der JavaScript Console des Browsers nachvollzogen werden.

{{< figure "Listing 5: Prinzip Closure" >}}
```html
<!DOCTYPE html><html><head><title>Prinzip Closure</title></head><body>
<script>

  function my_chart() {

    var conf = { "width": 600, "height": 400 };

    function chart(){/*create chart with conf*/}

    chart.render = function(){
      chart();
      return chart;
    };

    chart.width = function(value) {
      if (!arguments.length) return conf.width;
      conf.width = value;
      return chart;
    };

    return chart;
  }

</script></body></html>
```
{{< /figure >}}

<figure>
<img src="/slides/2015-06-09-d3js-data-driven-documents/assets/test-closure.png" alt="Test Closure in Browser Konsole"/>
<figcaption>Abbildung 5: Test Closure in Browser Konsole</figcaption>
</figure>

Wenn man nun noch wie in Listing 5 bei diesen Get- und Set-Funktionen wiederum die Funktion selbst zurückliefert, dann hat man die Basis für eine Methodenverkettung geschaffen. Wie man sieht, lohnt es sich, ein wenig Arbeit in eine kleine API zu stecken - als Gegenleistung bekommt man universell einsatzbare Charts, die je nach Gegebenheit initialisiert und zur Laufzeit angepasst werden können, um z.B. auf Userinteraktionen zu reagieren.


## Die Königsklasse: Physik-Simulationen

D3 bietet für verschiedene Anwendungsfälle sogenannte Layouts an. Das sind im Grunde schon die eben angesprochenen wiederverwendbaren Charts, aber auf einem generischem Level. Wir gehen das an dem Beispiel eines Force Layouts durch, einer beliebten, kräftebasierenden Darstellung von Netzwerken.

Die Besonderheit einer kräftebasierenden, selbstorganisierenden Netzwerkvisualisierung ist die dahinterliegende physikalische Simulation. D3 berechnet fortwährend die Positionen der Netzwerkknoten. Damit der Eindruck einer Animation entsteht, muß man natürlich die Knoten seines Graphen irgendwann einmal neu positionieren. Diese Arbeit nimmt einem D3 nicht ab. D3 bietet aber ein sogenanntes Tick Event an, welches ungefähr alle 20 Millisekunden feuert. Wenn man dann bei jedem Tickevent alle Knoten und Verbindungen des Netzwerks an die jeweils aktuelle Position der physikalischen Simulation verschiebt, bekommt man den Eindruck einer Animation. Die Animation des Netzwerkes hört dann auf, wenn sich die Simulation in einem kräftemäßig ausgewogenen Zustand befindet.

Listing 6 zeigt ein minimales, vollständig lauffähiges Script für ein Force Layout. Zuerst die Daten - diese dürften den meisten bekannt sein. Als Knoten nehmen wir die Mitarbeiter der EMP-Tabelle, als Links die Beziehung zum Vorgesetzten. Die Links beziehen sich auf die Knoten in der Reihenfolge ihres Erscheinens, es wird also keine Key Function eingesetzt, um die Knoten zu identifizieren. Dies ist ok, solange keine Updates auf den Graph erfolgen sollen, ansonsten wird es einem schwer fallen, die Knoten im DOM zu identifizieren.

{{< figure "Listing 6: Force Layout" >}}
```html
<!DOCTYPE html><html><head><title>Force Layout</title></head><body>
<svg id="v6"></svg><!--graph container-->
<script src="http://d3js.org/d3.v3.min.js"></script><script>

  var v6 = {}; v6.data = {};

  v6.data.nodes = [
    {"name":"King","dept":10},{"name":"Blake","dept":30},
    {"name":"Clark","dept":10},{"name":"Jones","dept":20},
    {"name":"Scott","dept":20},{"name":"Ford","dept":20},
    {"name":"Smith","dept":20},{"name":"Allen","dept":30},
    {"name":"Ward","dept":30},{"name":"Martin","dept":30},
    {"name":"Turner","dept":30},{"name":"Adams","dept":20},
    {"name":"James","dept":30},{"name":"Miller","dept":10}
  ];

  v6.data.links = [
    {"source":1,"target":0},{"source":2,"target":0},
    {"source":3,"target":0},{"source":7,"target":1},
    {"source":8,"target":1},{"source":9,"target":1},
    {"source":10,"target":1},{"source":12,"target":1},
    {"source":13,"target":2},{"source":4,"target":3},
    {"source":5,"target":3},{"source":6,"target":5},
    {"source":11,"target":4}
  ];

  v6.width = 300; v6.height = 225;

  v6.svg = d3.select("svg#v6")
    .attr("viewBox","0 0 " + v6.width + " " + v6.height)
    .attr("width","500px")
    .style("max-width","100%")
    .style("background-color","white");

  v6.color = d3.scale.category10();

  v6.force = d3.layout.force().size([v6.width,v6.height]);

  v6.links = v6.svg.selectAll("line").data(v6.data.links)
    .enter().append("line").style('stroke','#999');

  v6.nodes = v6.svg.selectAll("circle").data(v6.data.nodes)
    .enter().append("circle")
      .attr("r", 5)
      .style("fill", function(d){ return v6.color(d.dept); })
      .call(v6.force.drag);

  v6.force.on("tick", function(){
    v6.links
      .attr("x1", function(d){ return d.source.x; })
      .attr("y1", function(d){ return d.source.y; })
      .attr("x2", function(d){ return d.target.x; })
      .attr("y2", function(d){ return d.target.y; });

    v6.nodes
      .attr("cx", function(d){ return d.x; })
      .attr("cy", function(d){ return d.y; });
  });

  v6.force
    .nodes(v6.data.nodes)
    .links(v6.data.links)
    .start();

</script></body></html>
```
{{< /figure >}}

Will man z.B. die Knoten in Farbe und Größe passend zu den Daten gestalten, kann man auf die vielen Hilfsfunktionen von D3 zurückgreifen. Als Beispiel sei hier die Farbe der Knoten genannt. In Listing 6 kann man erkennen, wie die Variable `v6.color` mit der Funktion `d3.scale.category10()` belegt wird. Diese Funktion liefert eine aus 10 verschiedenen Farben für den übergebenen Wert zurück. Wir benutzen dies dafür, um über die Abteilungsnummer eines Mitarbeiters eine Farbe zurückzubekommen - somit haben alle Mitarbeiter einer Abteilung die gleiche Knotenfarbe, ohne dass wir dafür etwas programmieren müssen.

Nach der `v6.color` Variablen wird dann eine Variable `v6.force` mit dem entsprechenden Layout belegt. Dann folgt schon die Variable `v6.links`. Hier werden alle Linien im SVG Element selektiert - in unserem Fall ergibt das ein leeres Array, weil wir ja wissen, dass wir zum ersten Mal den Graph erstellen.

Dann folgt in der selben Zeile der Data Join mit unseren Links und gleich darauf wird in der Enter Selection für jeden Eintrag in unserem `v6.links` Array eine Linie im SVG Element gezeichnet. Das Ganze wiederholen wir jetzt für die Knoten.

Daraufhin definieren wir noch für das Tick Event die bereits erwähnte Funktion, die dann jeweils unsere Knoten und Links innerhalb des SVG Elementes positionieren. Man kann hier schön erkennen, wie D3 jeweils implizit über das `v6.links` und `v6.nodes` Array iteriert und für jeden Eintrag in der darauf definierten anonymen Funktion als ersten Parameter die Daten des Eintrags übergibt, die einem dann für die weitere Verarbeitung zur Verfügung stehen. In unserem Fall geben wir einfach nur die jeweilige Position für den Link oder den Knoten zurück.

Als letzter Schritt wird noch die eigentliche physikalische Berechnung gestartet, die natürlich unsere beiden Knoten und Link Arrays benötigt, um vernünftig arbeiten zu können. Als Ergebnis erhalten wir den Graph aus Abbildung 6, der schon ein wenig an den ersten Graphen am Anfang des Artikels erinnert.

<figure>
<svg id="v6" class="shadow" style="display:inline-block;"></svg><!--graph container-->
<figcaption>Abbildung 6: Das Ergebnis aus Listing 6 - Knoten dürfen bewegt werden ;-)</figcaption>
</figure>

Wie man sieht, muß man oft nur minimal Code erstellen, um Charts an seine eigenen Bedürfnisse anzupassen. Und sollte man doch mal etwas komplizierteres benötigen, so kann man davon ausgehen, im Internet viele Beispiele für die gleiche oder eine ähnliche Problemstellung zu finden.


## Netzwerken: Ein Plugin (nicht nur) für APEX

Wer sich dafür interessiert, was man noch so alles machen muss, um vom eben gezeigten Minimalbeispiel zu der großen Lösung aus dem Artikelanfang zu kommen, findet eine vollständige Implementierung eines Netzwerkcharts als [APEX-Plugin auf GitHub][8]. Dazu gibt es auch eine [Demo-App auf apex.oracle.com][9]. Allen Nicht-APEX-Entwicklern sei gesagt, dass trotz seines Namens nicht zwingend APEX benötigt wird. Wie im Artikel empfohlen existiert eine vollständige JavaScript API. Darüberhinaus gibt es einen interaktiven Customization Wizard und die Chartfunktion stellt bei nicht vorhandenen Daten selbstständig Beispieldaten zur Verfügung. Mit diesen Voraussetzungen kann man nach dem Einbinden der benötigten Source-Dateien sofort loslegen, Parameter verändern und live die Auswirkungen testen.

[8]: https://github.com/ogobrecht/d3-force-apex-plugin
[9]: https://apex.oracle.com/pls/apex/f?p=18290:1

## Fazit

Mit D3 stehen einem eine Menge Möglichkeiten offen, eigene Charts zu erstellen. Man muß zwar zuerst ein wenig Arbeit investieren, bekommt aber bei überlegter Umsetzung wiederverwendbaren Code und hat praktisch keine Einschränkungen in der Umsetzung. Natürlich kann man in einem Artikel wie diesem nur an der Oberfläche kratzen. Nichtsdestotrotz besteht die Hoffnung, Lust auf mehr gemacht zu haben. Folgend ein paar Links als Einstieg für die eigene Recherche:

- [d3js.org][10]
- [D3 Tip in der deutschen APEX Community][11]
- [www.apex-plugin.com][12] (nach D3 suchen)
- [apex.world][16] (Plugins, nach D3 suchen)
- [SVG Tutorial][13]

Wer keine Lust auf selber machen hat: [nvd3.org][14], [c3js.org][15] (Abstraktionsprojekte)

[10]: http://d3js.org
[11]: https://apex.oracle.com/pls/apex/germancommunities/apexcommunity/tipp/3481/index.html
[12]: http://www.apex-plugin.com/search-plugin-directory/
[13]: http://tutorials.jenkov.com/svg/index.html
[14]: http://nvd3.org/
[15]: http://c3js.org/
[16]: https://apex.world/ords/f?p=100:700

Happy coding :-)<br>
Ottmar

<link  href="/assets/d3.js/d3-force-3.0.0.css" rel="stylesheet" type="text/css">
<script src="/assets/d3.js/ResizeObserver-1.5.0.min.js"></script>
<script src="/assets/d3.js/d3-3.5.6.min.js"></script>
<script src="/assets/d3.js/d3-force-3.0.0.min.js"></script>

<style>.net_gobrechts_d3_force_tooltip { z-index: auto; }</style>

<script>
window.onload = function (){
  //v0
  window.v0 = netGobrechtsD3Force('v0')
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
  d3.select('#v0').select('svg').classed('shadow', true);
  //v1
  d3.select('svg#v1').append('circle')
    .attr('cx','380')
    .attr('cy','60')
    .attr('r','55')
    .style('stroke','red')
    .style('fill','lightsteelblue')
    .style('fill-opacity',0.5);
  //v3
  window.v3 = {};
  v3.div = d3.select('div#v3');
  v3.p = v3.div.selectAll('p').data([1,2,3])
    .style('color', 'red');
  v3.p.enter().append('p')
    .text( function(d){return 'Neues Element aus Daten ' + d;} );
  v3.p.exit().remove();
  //v4
  window.v4 = {};
  v4.data = [
    {"id":1, "r":14, "x":50,  "y":15, "color":"red"},
    {"id":2, "r":14, "x":70, "y":15, "color":"green"},
    {"id":3, "r":14, "x":90, "y":15, "color":"blue"}
  ];
  v4.svg = d3.select('svg#v4');
  v4.circles = v4.svg.selectAll('circle')
    .data(v4.data, function(d){return d.id;});
  v4.circles.exit().remove();
  v4.circles.enter().append('circle');
  v4.circles
    .attr('r',    function(d) { return d.r; })
    .attr('cx',   function(d) { return d.x; })
    .attr('cy',   function(d) { return d.y; })
    .attr('fill', function(d) { return d.color; });
  //v 6
  window.v6 = {}; v6.data = {};
  v6.data.nodes = [
    {"name":"King","dept":10},{"name":"Blake","dept":30},
    {"name":"Clark","dept":10},{"name":"Jones","dept":20},
    {"name":"Scott","dept":20},{"name":"Ford","dept":20},
    {"name":"Smith","dept":20},{"name":"Allen","dept":30},
    {"name":"Ward","dept":30},{"name":"Martin","dept":30},
    {"name":"Turner","dept":30},{"name":"Adams","dept":20},
    {"name":"James","dept":30},{"name":"Miller","dept":10}
  ];
  v6.data.links = [
    {"source":1,"target":0},{"source":2,"target":0},
    {"source":3,"target":0},{"source":7,"target":1},
    {"source":8,"target":1},{"source":9,"target":1},
    {"source":10,"target":1},{"source":12,"target":1},
    {"source":13,"target":2},{"source":4,"target":3},
    {"source":5,"target":3},{"source":6,"target":5},
    {"source":11,"target":4}
  ];
  v6.width = 300; v6.height = 225;
  v6.svg = d3.select("svg#v6")
    .attr("viewBox","0 0 " + v6.width + " " + v6.height)
    .attr("width","500px")
    .style("max-width","100%")
    .style("background-color","white");
  v6.color = d3.scale.category10();
  v6.force = d3.layout.force().size([v6.width,v6.height]);
  v6.links = v6.svg.selectAll("line").data(v6.data.links)
    .enter().append("line").style('stroke','#999');
  v6.nodes = v6.svg.selectAll("circle").data(v6.data.nodes)
    .enter().append("circle")
      .attr("r", 5)
      .style("fill", function(d){ return v6.color(d.dept); })
      .call(v6.force.drag);
  v6.force.on("tick", function(){
    v6.links
      .attr("x1", function(d){ return d.source.x; })
      .attr("y1", function(d){ return d.source.y; })
      .attr("x2", function(d){ return d.target.x; })
      .attr("y2", function(d){ return d.target.y; });
    v6.nodes
      .attr("cx", function(d){ return d.x; })
      .attr("cy", function(d){ return d.y; });
  });
  v6.force
    .nodes(v6.data.nodes)
    .links(v6.data.links)
    .start();
}
</script>
