# Aktionen – iPhone-App

Die App ist eine Capacitor-Hülle um die Web-App im Repo-Stamm (`../index.html`).
Gleiche Oberfläche, dazu echte iOS-Push-Benachrichtigungen für Lieblingsartikel.

## In Xcode öffnen
1. `ios/App/App.xcodeproj` doppelklicken (Xcode lädt beim ersten Öffnen Capacitor aus GitHub, ca. 1 Minute).
2. Links «App» anklicken → Reiter **Signing & Capabilities** → bei **Team** deine Apple-ID wählen.
3. Oben ein iPhone-Simulator wählen und ▶ drücken.

Auf dem eigenen iPhone: iPhone per Kabel anschliessen, oben auswählen, ▶.
Push-Benachrichtigungen funktionieren erst mit bezahltem Apple-Developer-Konto und nur auf einem echten iPhone.

## Web-Teil aktualisieren
Nach Änderungen an `../index.html`: `npm install` (einmalig), dann `npm run sync`.
Die Angebote lädt die App immer frisch von https://bsale9.github.io/-serl/aktionen.json.
