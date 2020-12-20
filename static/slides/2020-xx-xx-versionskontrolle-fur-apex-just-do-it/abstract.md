# Versionskontrolle für APEX - Just Do It

Viele Oracle Projekte setzen bis heute keine Versionskontrolle ein. Die Gründe dafür sind vielfältig. Meist geht man wohl davon aus, dass die Datenbank ein sicherer Ort für den Quellcode ist. Mit einem funktionierenden Backup ist das auch richtig, man verliert aber auf jeden Fall die komplette Historie der Änderungen.

Weitere Gründe für die Nutzung einer Versionskontrolle kommen aus der DevOps-Bewegung. Die Schlagworte hier sind Continuous Integration und  Continuous Delivery (CI/CD). Das kann man nur mit einer automatisierten Softwareauslieferung erreichen. Die Basis hierfür ist, dass alle Produktionsartefakte versioniert sind. Also neben dem Code auch Tests, Konfigurationen, Systemumgebungen, Deployment-Scripte usw..

Im APEX-Umfeld gibt es die zusätzliche Herausforderung, dass wir zuerst unsere Anwendung deklarativ erstellen und zum Schluss der Code in Form eines Anwendungsexportes entsteht. Per Default ist dies ein einziges großes SQL-Skript. Man kann so etwas zwar auch versionieren, der Nutzen hält sich aber in Grenzen.

Es wird gezeigt, wie man auch mit APEX eine sinnvolle, nutzbringende Versionierung einführen kann - und zwar auf Komponentenebene wie z.B. Seiten, Regionen, Elemente, Verarbeitungsprozesse, Navigation usw.. Daneben legen wir den Grundstein für CI/CD, indem wir darauf achten das gesamte Release per Skript wiederanlauffähig zu gestalten. Abschließend wird gezeigt, wie wir eine automatische Auslieferung der Anwendung mittels Jenkins erstellen können, wobei hier natürlich auch die Konfiguration der Softwareauslieferung nicht deklarativ in Jenkins erfolgt sondern per Deployment-Skript, welches aus der Versionskontrolle gezogen wird.
