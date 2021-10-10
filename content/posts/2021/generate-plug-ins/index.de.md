---
title: "APEX-Plug-ins auf der Kommandozeile generieren"
description: Anstelle neue Dateien in ein Plug-in hochzuladen generieren wir das Plug-in über ein Template auf der Kommandozeile und installieren es
tags: [Oracle, APEX, Plug-in , Debug, Instrumentation]
slug: "apex-plugins-generieren"
publishdate: 2021-10-30
lastmod: 2021-10-30 12:00:00
---

{{< toc >}}

## Einleitung

Alle, die Plug-ins für APEX entwickeln, kennen das Problem: Ist ein Plug-in erst einmal fertig, dann geht es bei der zukünftigen Pflege meistens nur darum, aktualisierte JavaScript-Dateien in das Plugin hochzuladen und zum Schluss das Plug-in herunterzuladen, um es für andere zur Verfügung zu stellen. Das kann ein sehr zeitaufwendiger Prozess sein, wenn man Fehler sucht oder ein neues Feature implementiert.

Für mein letztes Open-Source-Projekt habe ich mir deshalb überlegt, wie ich das Ganze abkürzen kann. Ich hatte sowieso schon einen File-Watcher laufen, der bei Änderungen von Quelldateien das komplette Projekt kompiliert. Im Plug-in ging es nur darum, eine JavaScript-Datei zu aktualisieren (normal und minifiziert). Der PL/SQL-Code für das Plug-in liegt in einem Package und wird nur referenziert - das ist auch aus Performance-Gründen ein gutes Vorgehen (FIXME: reference article from Daniel here).

## Erstellen eines Templates aus dem vorhandenen Plug-in

Ich habe also das fertige Plug-in einmalig heruntergeladen und als Template im Projektverzeichnis hinterlegt. Dann habe ich mir angeschaut, wie die Dateien im SQL-Script des Plug-ins hinterlegt werden:

{{< figure "Beispiel einer Datei im SQL-Installtionsskript eines Plug-ins" >}}
```sql
begin
  wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
  wwv_flow_api.g_varchar2_table(1) := '766172206f69633d7b6f633a7b7d2c6f613a7b7d2c6c6e3a7b7d7d3b6f69632e6c6e2e6572726f723d312c6f69632e6c6e2e7761726e696e673d322c6f69632e6c6e2e696e666f3d332c6f69632e6c6e2e64656275673d342c6f69632e6c6e2e74726163';
  wwv_flow_api.g_varchar2_table(2) := '653d352c6f69632e746f537472696e673d66756e6374696f6e2872297b666f7228766172206f3d22222c653d303b653c722e6c656e6774683b652b2b296f2b3d30213d3d653f2220223a22222c226f626a656374223d3d747970656f6620725b655d3f6f';
  wwv_flow_api.g_varchar2_table(3) := '2b3d225c6e222b4a534f4e2e737472696e6769667928725b655d2c6e756c6c2c32293a6f2b3d725b655d3b72657475726e206f7d2c6f69632e696e69743d66756e6374696f6e28297b6f69632e6d6573736167653d66756e6374696f6e28722c6f2c652c';
  wwv_flow_api.g_varchar2_table(4) := '6e297b617065782e7365727665722e706c7567696e286f69632e706c7567696e49642c7b7830313a722c7830323a6f2c7830333a22415045582046524f4e54454e44204a4156415343524950543a20222b652c7830343a6e2c7830353a6e617669676174';
  wwv_flow_api.g_varchar2_table(5) := '6f722e757365724167656e742c705f64656275673a21317d2c7b737563636573733a66756e6374696f6e2872297b225355434345535322213d7226266f69632e6572726f7228224f7261636c6520496e737472756d656e746174696f6e20436f6e736f6c';
  wwv_flow_api.g_varchar2_table(6) := '653a20414a41582063616c6c2068616420736572766572207369646520504c2f53514c206572726f723a20222b722b222e22297d2c6572726f723a66756e6374696f6e28722c6f2c65297b6f69632e6572726f7228224f7261636c6520496e737472756d';
  wwv_flow_api.g_varchar2_table(7) := '656e746174696f6e20436f6e736f6c653a20414a41582063616c6c207465726d696e617465642077697468206572726f72733a20222b652b222e22297d2c64617461547970653a2274657874227d297d2c6f69632e6f632e6572726f723d636f6e736f6c';
  wwv_flow_api.g_varchar2_table(8) := '652e6572726f722c636f6e736f6c652e6572726f723d66756e6374696f6e28297b6f69632e6d657373616765286f69632e6c6e2e6572726f722c6f69632e746f537472696e6728617267756d656e7473292c22636f6e736f6c652e6572726f7222292c6f';
  wwv_flow_api.g_varchar2_table(9) := '69632e6f632e6572726f722e6170706c7928636f6e736f6c652c617267756d656e7473297d2c6f69632e6f612e6572726f723d617065782e64656275672e6572726f722c617065782e64656275672e6572726f723d66756e6374696f6e28297b6f69632e';
  wwv_flow_api.g_varchar2_table(10) := '6d657373616765286f69632e6c6e2e6572726f722c6f69632e746f537472696e6728617267756d656e7473292c22617065782e64656275672e6572726f7222292c6f69632e6f612e6572726f722e6170706c7928617065782e64656275672c617267756d';
  wwv_flow_api.g_varchar2_table(11) := '656e7473297d2c77696e646f772e6f6e6572726f723d66756e6374696f6e28722c6f2c652c6e2c69297b6e3d2277696e646f772e6f6e6572726f722c2075726c20222b6f2e6d61746368282f5c2f5c2f2e2a3f285c2f2e2a292f295b315d2b222c206c69';
  wwv_flow_api.g_varchar2_table(12) := '6e6520222b652b222c20636f6c756d6e20222b6e3b72657475726e2d313c722e746f4c6f7765724361736528292e696e6465784f662822736372697074206572726f7222293f6f69632e6d657373616765286f69632e6c6e2e6572726f722c2253637269';
  wwv_flow_api.g_varchar2_table(13) := '7074206572726f7220696e20616e2065787465726e616c2066696c652028646966666572656e74206f726967696e293a205365652062726f7773657220636f6e736f6c6520666f722064657461696c73222c6e293a6f69632e6d657373616765286f6963';
  wwv_flow_api.g_varchar2_table(14) := '2e6c6e2e6572726f722c722c6e2c692e737461636b292c21317d7d3b';
end;
/

begin
  wwv_flow_api.create_plugin_file(
    p_id           => wwv_flow_api.id(37195131994077352)                           ,
    p_plugin_id    => wwv_flow_api.id(36295154520053378)                           ,
    p_file_name    => 'console.min.js'                                             ,
    p_mime_type    => 'application/javascript'                                     ,
    p_file_charset => 'utf-8'                                                      ,
    p_file_content => wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table) );
end;
/
{{< /figure >}}


Es sieht so aus, als müsste man die Dateien irgendwie kodieren - nur wie? Schaut man sich die Zeichen genauer an, fällt einem irgendwann auf, dass nur die Ziffern 0 bis 9 und die Buchstaben a bis f verwendet werden. Es scheint also eine Hexadezimal-Kodierung zu sein - mit jeweils 200 Zeichen in einem Block.

## JavaScript-Hilfsfunktionen für die Konvertierung

Da ich den File-Watcher und andere Skripte mit Node.js/npm umgesetzt habe, lag es nahe auch dies in JavaScript zu lösen. Zuerst brauchen wir das File-System- und Crypto-Modul:

```js
const fs = require('fs');
const crypto = require('crypto');
```

Dann eine Helfer-Funktion, die eine Zeichenkette in Blöcke von 200 Zeichen zerlegt und als Array zurückgibt:

```js
const toChunks = function (text, size) {
    const numChunks = Math.ceil(text.length / size)
    const chunks = new Array(numChunks)
    for (let i = 0, start = 0; i < numChunks; ++i, start += size) {
        chunks[i] = text.substr(start, size)
    }
    return chunks
};
```

Und schließlich unsere eigentliche Funktion, die eine Zeichenkette (eingelesene Datei) hexadezimal kodiert und in die benötigte SQL-Skriptform bringt:

```js
const toApexPluginFile = function (text) {
    const hexString = new Buffer.from(text).toString('hex')
    const chunks = toChunks(hexString, 200)
    let apexLoadFile = 'begin\n' +
        '  wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;\n'
    for (let i = 0; i < chunks.length; ++i) {
        apexLoadFile += `  wwv_flow_api.g_varchar2_table(${(i + 1)}) := '${chunks[i]}';\n`
    }
    apexLoadFile += 'end;\n/'
    return apexLoadFile
};
```

## Anpassung des Templates

Nun müssen wir das Template so anpassen, dass anstelle der Dateiinhalte Platzhalter stehen:

{{< figure "Beispiel einer Datei im Plug-in-Template" >}}
```sql
#CONSOLE_JS_FILE_MIN#

begin
  wwv_flow_api.create_plugin_file(
    p_id           => wwv_flow_api.id(37195131994077352)                           ,
    p_plugin_id    => wwv_flow_api.id(36295154520053378)                           ,
    p_file_name    => 'console.min.js'                                             ,
    p_mime_type    => 'application/javascript'                                     ,
    p_file_charset => 'utf-8'                                                      ,
    p_file_content => wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table) );
end;
/
```
{{< /figure >}}

## Build-Skript zum Bauen des Plug-ins bei Änderungen im Quellcode

{{< figure "Beispiel eines Build-Skriptes (Ausschnitt)" >}}
```sql
--snip--
console.log('- build file install/apex_plugin.sql');
const consoleJsCode = fs.readFileSync('sources/apex_plugin_console.js', 'utf8');
const version = fs.readFileSync('sources/CONSOLE.pks', 'utf8').match(/c_version\s+constant.*?'(.*?)'/)[1];
const md5Hash = toMd5Hash(consoleJsCode);
let conf = JSON.parse(fs.readFileSync('apexplugin.json', 'utf8'));
let minified;
if (conf.version !== version || conf.jsFile.md5Hash !== md5Hash) {
    // minify JS code
    minified = UglifyJS.minify({ "console.js": consoleJsCode }, { sourceMap: true });
    if (minified.error) throw minified.error;
    // build plug-in
    conf.version = version;
    conf.jsFile.md5Hash = md5Hash;
    conf.jsFile.version += 1;
    fs.writeFileSync('install/apex_plugin.sql',
        '--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT sources/build.js\n\n' +
        fs.readFileSync('sources/apex_plugin_template.sql', 'utf8')
            .replace('#CONSOLE_VERSION#', conf.version)
            .replace('#FILE_VERSION#', conf.jsFile.version)
            .replace('#CONSOLE_JS_FILE#', toApexPluginFile(fs.readFileSync('sources/apex_plugin_console.js', 'utf8')))
            .replace('#CONSOLE_JS_FILE_MIN#', toApexPluginFile(minified.code))
            .replace('#CONSOLE_JS_FILE_MIN_MAP#', toApexPluginFile(minified.map))
    );
    fs.writeFileSync('apexplugin.json', JSON.stringify(conf, null, 2));
}
--snip--
```
{{< /figure >}}

Zu beachten ist hier, dass wir auch die Dateiversion selber verwalten müssen - APEX installiert es so, wie wir es erstellen. Wir überprüfen dazu mit Hilfe einer Hash-Funktion, ob sich die JavaScript-Quelldatei geändert hat und generieren nur dann das Plug-in neu (inklusive Minifizierung). Somit verhindern wir, das bei jeder Änderung von Quellcode im Repository unnötigerweise das Plug-in neu generiert und damit die Dateiversion hochgezählt wird. Im obigen Build-Skript-Beispiel wird die aktuelle Dateiversion und der aktuelle Hash-Wert in einer JSON-Datei (`apexplugin.json`) gespeichert.

Hier die relevante Stelle im Plug-in-Template, wo die Dateiversion durch das Build-Skript eingetragen wird (Platzhalter `#FILE_VERSION#` in der drittletzten Zeile):

```sql
prompt - application/shared_components/plugins/dynamic_action/com_ogobrecht_console
begin
  wwv_flow_api.create_plugin (
    p_id                        => wwv_flow_api.id(36295154520053378)     ,
    p_plugin_type               => 'DYNAMIC ACTION'                       ,
    p_name                      => 'COM.OGOBRECHT.CONSOLE'                ,
    p_display_name              => 'Oracle Instrumentation Console'       ,
    p_supported_ui_types        => 'DESKTOP:JQM_SMARTPHONE'               ,
    p_api_version               => 2                                      ,
    p_render_function           => 'console.apex_plugin_render'           ,
    p_ajax_function             => 'console.apex_plugin_ajax'             ,
    p_substitute_attributes     => true                                   ,
    p_subscribe_plugin_settings => true                                   ,
    p_version_identifier        => '#CONSOLE_VERSION#'                    ,
    p_about_url                 => 'https://github.com/ogobrecht/console' ,
    p_files_version             => #FILE_VERSION#                         );
end;
/
```

Zusätzlich wird hier auch noch die Versionsnummer des Plug-ins selbst aktualisiert (Platzhalter `#CONSOLE_VERSION#` in der fünftletzten Zeile) - das hängt aber von den jeweiligen Gegebenheiten des Projektes ab. Bei mir ist es so, dass ich die Versionsnummer des PL/SQL-Packages CONSOLE auch in das davon abhängige Plug-in schreibe - wenn sich also die Versionsnummer des Packages ändert wird auch das Plug-in neu erstellt. Hier muss aber jeder schauen, was er in seinem Projekt braucht.

Beim Speichern von Quellcode-Änderungen springt der File-Watcher an und triggert das Build-Skript. Dieses baut dann zwei Installations-SQL-Skripte zusammen: Einmal das des Logging-Tools selbst (nicht im Fokus diese Artikels) und dann das für das Plug-in. Im Anschluss daran werden dann beide Skripte in einer Test-Umgebung installiert. Dazu muss natürlich der im Plug-in hinterlegte Default-Workspace und die Default-Anwendungsnummer in der Test-Umgebung vorhanden sein.

## npm Skripte zur Orchestrierung

Build- und Installtionsskripte verwalte ich mittlerweile häufig mit dem Node-Package-Manager npm. Der Grund dafür ist die gute Integration in Visual Studio Code, die Betriebssystemunabhängikeit und die Möglichkeit die Skripte ein wenig zu orchestrieren - ok, man muss Node.js installieren, aber hat man das nicht immer? Man kann dann mit einem Klick entweder den watch-Task starten, der alles automatisch macht mit jedem Speichervorgang einer Quelldatei oder eben die Skripte bequem einzeln aufrufen. Wenn mal wer anders ins Repository schaut, ist es auch mit den npm-Skripten schneller klar, was hier wie gelöst ist.

{{< figure "npm Script-Integration in VS Code: Links die Skripte zum Anklicken, rechts die geöffnete Datei package.json" >}}
![Screenshot: npm script integration in VS Code](npm-scripts.png)
{{< /figure >}}

Klar ist auch, dass man hier nicht mehr Usernamen und Passwörter in die Skripte schreibt - das verbietet sich schon prinzipiell, wenn der Code in die Versionskontrolle eingecheckt wird. Auf dem Screenshot kann man (hoffentlich) erkennen, dass hier ein Wallet mit dem Alias `playground` bemüht wird.

Verwaltet werden die Skripte in der Datei `package.json` auf der obersten Ebene des Projektverzeichnisses:

Wer mehr zum Thema npm-Skripte lesen möchte, kann hier anfangen:

- [Introduction to NPM Scripts](https://medium.freecodecamp.org/introduction-to-npm-scripts-1dbb2ae01633)
- [Why I Left Gulp and Grunt for npm Scripts](https://medium.freecodecamp.org/why-i-left-gulp-and-grunt-for-npm-scripts-3d6853dd22b8)
- [Why npm Scripts?](https://css-tricks.com/why-npm-scripts/)

Hier noch zwei Artikel zu Wallets mit dem Instant-Client:

- fixme: artikel übersetzen nach deutsch und link einfügen
- fixme: artikel übersetzen nach deutsch und link einfügen

## Ein komplettes Beispiel

Wer sich anschauen möchte, wie alles zusammen funktionieren kann: Die Beispiele hier im Artikel habe ich aus meinem Open-Source-Projekt [Oracle Instrumentation Console](https://github.com/ogobrecht/console) entnommen.

Viel Spaß beim Plug-In skripten :-)

Ottmar
