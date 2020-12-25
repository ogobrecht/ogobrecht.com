## Rethink Table API's, Fast Development, Secure Access
**André Borngräber, Ottmar Gobrecht**<br>
APEX Meetup 17.06.2016, Frankfurt

-----

## Warum?

---

### Schnelligkeit

- Standardcalls für CRUD-Operationen
- Hilfsmethoden für eindeutige Schlüssel

---

### Lesbarkeit

- Kürzerer Code
- Einheitliche Methodennamen
- Wiedererkennungseffekte

---

### Wartbarkeit

- API's generierbar
- Strukturänderungen einfacher durchführbar
- Invalide API-Calls in Businesslogik schnell behebbar

---

### Sicherheit

- Trennung zwischen Daten- und UI-Schema einfach
- Löschen von Datensätzen abschaltbar

---

### Historisierung, Logging

- API feuert nur bei Änderungen
- Keine unnötigen Zeilen bei Updates

---

### Kompatibilität

- APEX Wizard getriebene Formulare werden unterstützt (Multirow-DML)
    - View und Instead Of Trigger werden generiert pro Tabelle
    - Trigger ruft API auf
	- APEX Prüfung auf veränderte Zeilen bleibt erhalten

---

### One Last Thing: Avoid Hard-Coding SQL

... [sagt Steven Feuerstein][1]

Keine versteckten DML Statements in APEX

- Prozessen
- Dynamic Actions
- Validierungen
- ...

[1]: https://www.toadworld.com/cfs-file/__key/communityserver-wikis-components-files/00-00-00-00-03/Say-Goodbye-to-Hard_2D00_Coding.pdf

-----

## Wie?

---

### Open Source Projekt

[github.com/OraMUC/table-api-generator][2]

[2]: https://github.com/OraMUC/table-api-generator

---

PL/SQL & SQL Developer Integration ([oddgen][3])

```sql
begin
  om_tapigen.compile_only (p_table_name => 'EMP');
end;
```

![SQL Developer](./assets/sql-developer.png)

[3]: https://www.oddgen.org/

---

### Features

- Generiert schmale, übersichtliche API-Packages
- Löschen von Zeilen kann deaktiviert werden
- Spalten- und zeilenbasierte CRUD-Methoden
- Getter und Setter für jede Spalte
- Optionales Sequence-Handling
- Optionales generisches Logging
- Hilfsfunktionen:
  - `row_exists`
  - `get_pk_by_unique_cols`

---

### Konventionen

Der API-Generator setzt aktuell voraus, dass ...

- ... es einen einspaltigen, numerischen Primärschlüssel gibt ([Surrogatschlüssel][4], kein [sprechender Schlüssel][5])
- ... fachliche Schlüssel als eindeutige Schlüssel definiert werden (optional, dann wird pro Unique Key eine `get_pk_by_unique_cols` Funktion erstellt)

[4]: https://de.wikipedia.org/wiki/Surrogatschl%C3%BCssel
[5]: https://de.wikipedia.org/wiki/Sprechender_Schl%C3%BCssel

-----

## Beispiele

---

### Demozeit ...

-----

## Nächste Schritte

---

### In Planung

- ~~Generierungsoptionen in API-Packages hinterlegen~~
- Dokumentation
- Logger-Integration
- Historisierung über Parameter aufnehmen? [Slowly Changing Dimensions (Typ 2)][6]
- Eure Wünsche und Ideen?
- ...

[6]: https://de.wikipedia.org/wiki/Slowly_Changing_Dimensions

---

## The End

### Fragen?

Euer [OraMUC-Team][7]<br>
André & Ottmar

[7]: https://github.com/OraMUC
