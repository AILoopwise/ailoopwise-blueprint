# PRD: Vereins-Rundbrief

<!-- Ausgefülltes Beispiel zu PRD-TEMPLATE.md. Verein, Namen und Inhalte sind erfunden.
English: a filled example of PRD-TEMPLATE.md for a fictional sports club; the English outline is in PRD-TEMPLATE.md. -->

## Ziel
Ein kleiner Sportverein will seinen Mitgliedern einmal im Monat einen Rundbrief per E-Mail schicken, ohne ein teures Newsletter-Abo. Das Tool sammelt Anmeldungen auf der Vereinsseite und verschickt einen in Markdown geschriebenen Rundbrief.

## Nutzer
- **Mitglied / Interessent:** trägt auf der Vereinsseite seine E-Mail-Adresse ein und will sich jederzeit mit einem Klick abmelden können.
- **Vorstand (eine Person):** schreibt den Rundbrief als Markdown-Datei, schickt erst eine Testmail an sich selbst und dann an alle.

## Umfang erste Version
- Anmeldeformular mit Double-Opt-in (Bestätigungslink per Mail)
- Abmelde-Link in jeder Mail
- Versand einer Markdown-Datei als HTML-Mail an alle bestätigten Abonnenten
- CSV-Export der Abonnentenliste

## Nicht in der ersten Version
- Öffnungs- und Klickstatistiken
- Mehrere Listen oder Zielgruppen
- Ein Editor im Browser (der Rundbrief bleibt eine Datei)

## Funktionen
| # | Funktion | Abnahmekriterium |
|---|----------|------------------|
| 1 | Anmeldung | Formular speichert die Adresse als "pending" und schickt einen Bestätigungslink |
| 2 | Bestätigung | Klick auf den Link setzt "confirmed"; ein abgelaufener Link zeigt eine klare Fehlermeldung |
| 3 | Versand | `npm run send -- rundbrief.md --test` geht nur an die Vorstandsadresse; ohne `--test` an alle bestätigten Abonnenten |
| 4 | Abmeldung | Link in jeder Mail setzt "unsubscribed"; die Adresse bekommt keine weitere Mail |
| 5 | Export | `npm run export` schreibt eine CSV mit Adresse, Status und Anmeldedatum |

## Daten
- SQLite-Datei `data/subscribers.db`: E-Mail-Adresse, Status, Zeitpunkt der Anmeldung und Bestätigung
- Keine Namen, keine weiteren Daten. Abgemeldete Adressen bleiben mit Status "unsubscribed" gespeichert, damit sie nie wieder angeschrieben werden.

## Regeln, die die KI nie brechen darf
- Nie an echte Abonnenten senden, außer der Befehl wird ohne `--test` bewusst von mir gestartet.
- Nie den Zugangsschlüssel des Mail-Dienstes in Code oder Git schreiben. Er steht nur in `.env`.
- Nie Abonnenten löschen oder die Datenbank neu anlegen, ohne vorher eine Kopie zu machen.

## Technik
- Sprache / Framework: Node.js mit TypeScript, kleiner HTTP-Server für Formular und Links
- Datenbank: SQLite
- Mailversand: ein Mail-Dienst mit API, Schlüssel in `.env`
- Befehle: Build `npm run build` · Test `npm test` · Lint `npm run lint`

## Offene Fragen
- Welcher Mail-Dienst? (Entscheidung Vorstand)
- Wer ist im Impressum und in der Datenschutzerklärung der Vereinsseite für den Rundbrief genannt?
