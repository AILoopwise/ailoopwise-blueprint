# AILoopwise Blueprint

**Ein fertiges Setup für Claude Code, für Menschen, die nicht programmieren.** Es gibt jedem Projekt eine Regeldatei, ein Aufgaben-Gedächtnis, das die Nacht übersteht, fertige Skills und Helfer-Agenten, und Schutz-Hooks, die verhindern, dass die KI deine Arbeit zerstört.

[![install-test](https://github.com/AILoopwise/ailoopwise-blueprint/actions/workflows/install-test.yml/badge.svg)](https://github.com/AILoopwise/ailoopwise-blueprint/actions/workflows/install-test.yml)
[![release](https://img.shields.io/github/v/release/AILoopwise/ailoopwise-blueprint)](https://github.com/AILoopwise/ailoopwise-blueprint/releases/latest)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

[English](README.md) · Deutsch

## Warum es das gibt

Claude Code ist stark, aber es beginnt jede Sitzung, ohne etwas über dein Projekt zu wissen. Es vergisst, was es gestern getan hat, es weiß nicht, was es nie anfassen darf, und ein falscher Befehl kann einen Ordner löschen oder deine Git-Historie umschreiben.

Der Blueprint löst das mit einfachen Dateien, die du lesen kannst:

| Problem | Was der Blueprint ergänzt |
|---|---|
| Die KI kennt dein Projekt nicht | `CLAUDE.md`: was das Projekt ist, für wen, und welche Regeln gelten |
| Sie vergisst, wo sie aufgehört hat | `tasks/current.md`, `tasks/lessons.md`, `tasks/todo.md`: am Ende einer Sitzung geschrieben, am Anfang der nächsten gelesen |
| Du wiederholst dieselben Anweisungen | Skills: wiederverwendbare Anleitungen für Programmierung, Design, Marketing und Vertrieb |
| Ein Agent macht alles | Drei Helfer-Agenten: Recherche, Umsetzung und Prüfung |
| Ein Befehl kann Arbeit zerstören | Schutz-Hooks, die vor jedem Befehl laufen und die gefährlichen blockieren |

## Schnellstart

1. **Installiere Claude Code** mit [Anthropics Anleitung](https://code.claude.com/docs/de/setup) und installiere [jq](https://jqlang.org/download/) (die Schutz-Hooks brauchen es).
2. **Lade** [ailoopwise-blueprint.zip](https://github.com/AILoopwise/ailoopwise-blueprint/releases/latest/download/ailoopwise-blueprint.zip) **herunter**, entpacke es als `~/ailoopwise-blueprint` in deinen Benutzerordner und öffne diesen Ordner in VS Code mit der Claude-Code-Erweiterung.
3. **Füge einen Prompt ein.** Claude Code stellt dir drei Fragen und baut dein erstes Projekt in einem neuen Ordner:

```text
Du richtest mir den AILoopwise Blueprint ein. Ich bin kein Entwickler, erkläre alles in einfachen Worten.

1. Lies blueprint/MASTER-BLUEPRINT.md in diesem Ordner.
2. Erkläre mir den Aufbau des Blueprints in genau fünf kurzen Zeilen.
3. Stell mir dann diese drei Fragen, eine nach der anderen, und warte jeweils auf meine Antwort:
   a) An welchem Projekt willst du arbeiten?
   b) Was verkaufst du, und an wen?
   c) Was darf die KI in diesem Projekt niemals tun?
4. Führe danach /new-project aus. Falls der Befehl nicht verfügbar ist, lies blueprint/skills/new-project/SKILL.md und folge den Schritten selbst. Nutze meine drei Antworten als Eingaben und frag nur nach, was dann noch fehlt.
5. Lege das neue Projekt in einem NEUEN Ordner neben diesem an (Name nach meinem Projekt), nicht im Blueprint selbst. Es muss enthalten: .claude/CLAUDE.md sowie tasks/current.md, tasks/lessons.md und tasks/todo.md.
6. Schreib meine Antwort auf Frage c) als feste Regeln in die CLAUDE.md des neuen Projekts.
7. Ändere nichts in diesem Blueprint-Ordner. Zeig mir zum Schluss, welche Dateien du angelegt hast, und sag mir, wie ich das neue Projekt in VS Code öffne.
```

Unter Windows nutze WSL 2 oder installiere vorher [Git for Windows](https://git-scm.com/download/win): Die Schutz-Hooks sind Bash-Skripte und laufen ohne eins von beiden nicht. Schritt-für-Schritt-Seiten zu jedem Teil findest du in [`course/`](course/README.md).

## Der Befehls-Wächter

Bevor Claude Code einen Shell-Befehl ausführt, liest der Wächter ihn und entscheidet. Er stoppt die Befehle, die Arbeit vernichten, und lässt normale Arbeit in Ruhe.

| Blockiert | Erlaubt |
|---|---|
| `rm -rf ~`, `rm -rf .`, `rm -rf *` | `rm -rf node_modules dist .next` |
| `rm -rf .git` | `git restore --staged file.txt` |
| `git reset --hard`, `git clean -fdx` | `git clean -n` (Probelauf) |
| `git push --force` | `git push --force-with-lease` |
| `prisma migrate reset`, `docker compose down -v` | `docker compose down` |
| `.env`-Dateien lesen | in `.env.local` schreiben |

- Er schaut auch in Ketten, Subshells, `bash -c "…"`, `$( … )`, `if`/`for`-Blöcke und `git -C <ordner>`.
- **Wenn die Prüfung selbst scheitert** (Absturz, Zeitüberschreitung, zu große Eingabe), wird der Befehl blockiert, nicht durchgewunken. Der Befehls-Wächter funktioniert auch ohne `jq`; die anderen Schutz-Hooks blockieren Änderungen, bis `jq` installiert ist.
- Seine Testmatrix mit 716 Fällen läuft bei jeder Änderung, unter Linux, macOS und Windows.
- Bekannte Grenzen stehen oben in [`block-dangerous-commands.sh`](blueprint/hooks/block-dangerous-commands.sh). Er ist ein Sicherheitsnetz, keine Sandbox.

Andere Hooks prüfen Änderungen auf Geheimnisse, schützen sensible Dateien und führen am Ende einer Sitzung die Prüfungen deines Projekts aus. Diese Prüfungen laufen nur in Projekten, die du auf deinem eigenen Rechner mit dem Blueprint eingerichtet hast, nie in einem Ordner, den du gerade heruntergeladen hast.

## Was drin ist

```text
README.md, Install-guide.md      hier anfangen
course/                          eine Seite pro Videofolge, mit Beispielen
blueprint/MASTER-BLUEPRINT.md    wie alle Teile zusammenpassen
blueprint/global-claude.md       Vorlage für deine persönliche ~/.claude/CLAUDE.md
blueprint/project-templates/     CLAUDE.md-Vorlagen für Programmier-, Marketing- und Vertriebsprojekte
blueprint/skills/                new-project, onboarding und mehr, plus Pakete für Programmierung, Design, Marketing, Vertrieb
blueprint/agents/                Recherche, Umsetzung, Prüfung
blueprint/hooks/                 die Schutz-Hooks und ihre Testmatrizen
blueprint/scripts/               bootstrap.sh und blueprint-sync.sh (Installation und Update)
```

## Die Videoreihe

1. **Installation**: Claude Code installieren und das erste Mal starten.
2. **Desktop einrichten**: VS Code, die Erweiterung und dieser Blueprint.
3. **Server (optional)**: Claude Code auf einem eigenen Server laufen lassen.
4. **Leitplanken**: Hooks und Regeln, die gefährliche Befehle und Geheimnisse abfangen.
5. **Projektstart per Sprache**: ein Projekt einsprechen statt eintippen.
6. **Lange Sitzungen**: Kontext, Aufgabendateien und wie die KI am nächsten Tag weitermacht.

Videos und Updates: [ailoopwise.com/de/starter](https://www.ailoopwise.com/de/starter)

## Häufige Fragen

**Ist es kostenlos?** Ja. MIT-Lizenz, kein Konto, kein Tracking. Keine Telemetrie: nichts meldet sich bei uns. Zwei Dinge gehen bewusst online: Die Abhängigkeitsprüfung fragt beim Installieren von Paketen die npm-Registry nach bekannten Schwachstellen, und die optionalen MCP-Server in `blueprint/mcp/` verbinden sich mit ihren Diensten, wenn du sie einschaltest.

**Muss ich programmieren können?** Nein. Du fügst einen Prompt ein und beantwortest drei Fragen. Die Kursseiten erklären jeden Schritt in einfachen Worten.

**Verändert es meinen Rechner?** Der Schnellstart legt einen neuen Projektordner an und trägt seinen Pfad in `~/.claude/blueprint-projects` ein, die Liste der Projekte, deren eigene Prüfungen laufen dürfen. Die optionale globale Installation (`blueprint/scripts/bootstrap.sh`, siehe [Install-guide.md](Install-guide.md)) fügt die Hooks in `~/.claude` hinzu, führt sie mit deinen bestehenden Einstellungen zusammen, ohne etwas zu entfernen, und legt vorher eine datierte Sicherung an.

**Wie aktualisiere ich?** Ersetze den Ordner `~/ailoopwise-blueprint` durch das neue Release, führe `bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --dry-run` aus, um zu sehen, was sich ändern würde, und denselben Befehl ohne `--dry-run`, um es anzuwenden. Dateien, die du bearbeitet hast, werden nie überschrieben; die neue Fassung landet daneben als `.blueprint-new`.

**Wie entferne ich es?** Lösch den Ordner `.claude/` im Projekt und führe `bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --unregister <Projektordner>` aus. Für die globale Installation folge [Remove the global install](Install-guide.md#want-to-remove-the-global-install) in der Installationsanleitung.

**Macht die KI trotzdem Fehler?** Ja. Regeln und Hooks machen Fehler seltener und weniger teuer, aber nicht unmöglich. Prüf, was sie tut, und führ die Prüfungen selbst aus.

## Mitmachen und Sicherheit

Issues und Ideen sind willkommen, siehe [CONTRIBUTING.md](CONTRIBUTING.md). Eine Schwachstelle meldest du nach [SECURITY.md](SECURITY.md), bitte nicht als öffentliches Issue.

## Lizenz

MIT, siehe [LICENSE](LICENSE). Die Vorlagen sind leere Formen; alle Beispiele darin (Firmen, Personen, Zahlen) sind erfunden.

AILoopwise ist nicht mit Anthropic verbunden und wird von Anthropic weder unterstützt noch gesponsert. Claude und Claude Code sind Marken von Anthropic, PBC.
