-----

<!-- .slide: data-background-image="/assets/images/danielle-macinnes-IuLgi9PWETU-unsplash.jpg" -->
<!-- .slide: data-background-image="/assets/images/michael-d-beckwith-575798-unsplash.jpg" -->

# Motivation

---

## Anmerkungen Erstexport

- Zip file nur beim allerersten Schritt sinnvoll/notwendig
- Später sollte man Skripte benutzen
- Siehe auch Ordner Zip/scripts/templates

---

## SYS-Objekte

Vor Export umbenennen oder bei Export exkludieren

Ziel: Keine SYS-Objekte im Repository

---

## Anpassen File Collection

```sql
DECLARE
  l_files plex.tab_export_files;
BEGIN
  l_files := plex.backapp(p_app_id => 100);

  FOR i IN 1..l_files.count LOOP
    l_files(i).name := /*your code here*/;
    l_files(i).contents := /*your code here*/;
  END LOOP;
END;
```

---

## Unser Ziel - Deployment Templements

- Jeweils EIN SQL-Skript
  - Export App
  - Install App
- Je Zielsystem ein Shell-Wrapper
  - DEV
  - INT
  - PROD
- Log für alle Schritte

---

## Was wir jetzt haben
- Übersichtliches Repository
- Dateibasiertes Arbeiten
- Immer Skripte
- Wiederanlauffähigkeit
- Deployment-Vorlagen

---

## Was Euch erwartet
- Motivation: DevOps, der erste Schritt
- Toolvergleich: Export Schema DDL
- Repositoryaufbau: Tool PLEX
- DDL: Skripte & Wiederanlauffähigkeit
- Mehr Tools: Git-Client, Editor, Liquibase
- Fazit & nächste Schritte

---

## Überspitzt formuliert

In einem Reifegradmodell wären wir jetzt fertig.

- Wir nutzen Versionskontrolle
- Fein, abgehakt, erledigt

In einem Kompetenzmodell schauen wir, was wir noch verbessern können und lernen ständig hinzu...

---

## Wer es nicht lassen kann...

Wege hin zum dateibasierten Arbeiten... <!-- .element: class="fragment"-->

```sql
DECLARE
  l_file_collection plex.tab_export_files;
BEGIN
  l_file_collection := plex.backapp(
    ...
    p_object_type_not_like => 'TABLE,MY_TYPE%',
    p_object_name_not_like => 'LOGGER%,PLEX,MY_LIB%',
    ...
  );

...
```
<!-- .element: class="fragment"-->
