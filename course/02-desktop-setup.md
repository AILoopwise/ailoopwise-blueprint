# Folge 2 · Desktop einrichten (VS Code)

**Deutsch** · [English](#english) · [Übersicht](README.md) · Zurück: [Folge 1](01-installation.md) · Weiter: [Folge 3](03-server-optional.md)

Wer KI wirklich für sich arbeiten lassen will, chattet nicht mehr im Browser. Du richtest sie direkt in deiner Arbeitsumgebung ein: VS Code öffnen, die offizielle Claude-Code-Erweiterung installieren, mit deinem claude.ai-Konto verbinden. Ab dann sieht die KI den Inhalt deiner Ordner und arbeitet direkt in deinen Dateien. Mit einem einzigen Prompt legt sie dir danach dein erstes Projekt mit dem Blueprint an.

Der Haken: Die Session läuft auf deinem Laptop. Klappst du ihn zu oder beendest VS Code, stoppt sie. Das löst Folge 3.

## Was du am Ende hast

- VS Code mit der Claude-Code-Erweiterung, angemeldet mit deinem Claude-Konto.
- Einen neuen Projektordner neben dem Blueprint, mit `.claude/CLAUDE.md` und `tasks/current.md`, `tasks/lessons.md`, `tasks/todo.md`.
- Deine Antwort auf „Was darf die KI niemals tun?“ als feste Regeln in dieser CLAUDE.md.

## Was du brauchst

- Claude Code aus [Folge 1](01-installation.md) und den Ordner `~/ailoopwise-blueprint`
- **VS Code 1.94.0 oder neuer:** https://code.visualstudio.com
- **Die Claude-Code-Erweiterung**, Anleitung: https://code.claude.com/docs/de/vs-code
- Dein Claude-Konto (Pro, Max, Team, Enterprise oder Console). Ein API-Schlüssel ist nicht nötig.

## Schritt für Schritt

1. Installiere VS Code und starte es.
2. Öffne die Erweiterungen mit `Cmd+Shift+X` (Mac) oder `Ctrl+Shift+X` (Windows/Linux), suche **Claude Code** und klicke **Install**.
3. **Datei → Ordner öffnen…** und wähle `~/ailoopwise-blueprint`. Fragt VS Code, ob du dem Ordner vertraust, antworte mit Ja.
4. Öffne eine beliebige Datei, zum Beispiel `README.md`. Klicke oben rechts im Editor auf das Spark-Symbol. Das Claude-Panel öffnet sich.
5. Klicke **Sign in** und bestätige im Browser.
6. Kopiere diesen Prompt vollständig ins Claude-Panel und drücke Enter. Es ist derselbe Prompt wie in der `README.de.md` des Blueprints:
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
7. Beantworte die drei Fragen. Bei Frage c) sei konkret: „Nie an echte Kunden mailen“ wirkt, „vorsichtig sein“ nicht.
8. Claude fragt vor dem Anlegen von Dateien und vor Befehlen um Erlaubnis. Lies kurz, was es tun will, und erlaube es.
9. Öffne den neuen Projektordner mit **Datei → Ordner öffnen…** und starte dort eine neue Claude-Session. Prüfe:
   ```text
   Lies .claude/CLAUDE.md und nenne mir die festen Regeln in höchstens drei Zeilen.
   ```

## Beispiel zum Kopieren

So sieht eine fertige Projektdatei aus: [examples/CLAUDE-example.md](examples/CLAUDE-example.md). Deine Antwort auf Frage c) landet in einem Block wie diesem:

```markdown
## Hard rules (the AI must never)
- Send to real subscribers. Every send command you run uses --test.
- Write the mail API key into code, tests or git. It lives only in .env.
- Drop or recreate data/subscribers.db without making a copy first.
```

Die Vorlagen des Blueprints sind englisch. Du kannst deine Regeln trotzdem auf Deutsch schreiben.

## Bevor du zur nächsten Folge gehst

Öffne die `.claude/CLAUDE.md` deines neuen Projekts und lies deine festen Regeln einmal selbst. Fehlt eine, schreib sie jetzt dazu.

## Wenn etwas hakt

- **Kein Spark-Symbol zu sehen:** Es erscheint nur, wenn eine Datei offen ist. Außerdem: VS Code 1.94.0 oder neuer, Fenster neu laden („Developer: Reload Window“), und der Ordner darf nicht im eingeschränkten Modus (Restricted Mode) geöffnet sein. Quelle: https://code.claude.com/docs/de/vs-code#spark-icon-not-visible
- **Die Erweiterung lässt sich nicht installieren:** VS Code-Version prüfen und direkt aus dem Marketplace installieren: https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code
- **`claude` im VS-Code-Terminal wird nicht gefunden:** Die Erweiterung bringt eine eigene Kopie mit, legt `claude` aber nicht in deinen Suchpfad. Für das Terminal brauchst du die Installation aus Folge 1.
- **Claude findet den Blueprint-Ordner nicht:** Sag es ihm direkt: `My blueprint folder is at ~/ailoopwise-blueprint/blueprint/` (aus `Install-guide.md`, Troubleshooting).

---

## English

[Overview](README.md) · Back: [Episode 1](01-installation.md) · Next: [Episode 3](03-server-optional.md)

If you want AI doing real work, stop chatting in a browser tab. You set it up right inside your workspace: open VS Code, install the official Claude Code extension, link it to your claude.ai account. From then on the AI sees what is in your folders and works directly in your files. One single prompt then sets up your first project with the blueprint.

The catch: the session runs on your laptop. Close the lid or quit VS Code and it stops. Episode 3 solves that.

### What you'll have at the end

- VS Code with the Claude Code extension, signed in with your Claude account.
- A new project folder next to the blueprint, with `.claude/CLAUDE.md` plus `tasks/current.md`, `tasks/lessons.md`, `tasks/todo.md`.
- Your answer to "What must the AI never do?" written as hard rules into that CLAUDE.md.

### What you need

- Claude Code from [episode 1](01-installation.md) and the folder `~/ailoopwise-blueprint`
- **VS Code 1.94.0 or later:** https://code.visualstudio.com
- **The Claude Code extension**, guide: https://code.claude.com/docs/en/vs-code
- Your Claude account (Pro, Max, Team, Enterprise or Console). No API key needed.

### Step by step

1. Install VS Code and start it.
2. Open Extensions with `Cmd+Shift+X` (Mac) or `Ctrl+Shift+X` (Windows/Linux), search **Claude Code** and click **Install**.
3. **File → Open Folder…** and pick `~/ailoopwise-blueprint`. When VS Code asks whether you trust the folder, say yes.
4. Open any file, for example `README.md`. Click the Spark icon at the top right of the editor. The Claude panel opens.
5. Click **Sign in** and confirm in your browser.
6. Copy this prompt in full into the Claude panel and press Enter. It is the same prompt as in the blueprint's `README.md`:
   ```text
   Set up the AILoopwise Blueprint for me. I am not a developer, so explain everything in plain words.

   1. Read blueprint/MASTER-BLUEPRINT.md in this folder.
   2. Explain how the blueprint is structured in exactly five short lines.
   3. Then ask me these three questions, one at a time, and wait for each answer:
      a) Which project do you want to work on?
      b) What do you sell, and to whom?
      c) What must the AI never do in this project?
   4. Then run /new-project. If that command is not available, read blueprint/skills/new-project/SKILL.md and follow its steps yourself. Use my three answers as the inputs and only ask for what is still missing.
   5. Create the new project in a NEW folder next to this one (named after my project), not inside the blueprint itself. It must contain: .claude/CLAUDE.md plus tasks/current.md, tasks/lessons.md and tasks/todo.md.
   6. Write my answer to question c) into the new project's CLAUDE.md as hard rules.
   7. Do not change anything in this blueprint folder. At the end, show me which files you created and tell me how to open the new project in VS Code.
   ```
7. Answer the three questions. For question c) be concrete: "never email real customers" works, "be careful" does not.
8. Claude asks for permission before it creates files or runs commands. Read what it wants to do, then allow it.
9. Open the new project folder with **File → Open Folder…** and start a new Claude session there. Check:
   ```text
   Read .claude/CLAUDE.md and list its hard rules in three lines at most.
   ```

### Example to copy

A finished project file looks like this: [examples/CLAUDE-example.md](examples/CLAUDE-example.md). Your answer to question c) lands in a block like this:

```markdown
## Hard rules (the AI must never)
- Send to real subscribers. Every send command you run uses --test.
- Write the mail API key into code, tests or git. It lives only in .env.
- Drop or recreate data/subscribers.db without making a copy first.
```

### Before the next episode

Open your new project's `.claude/CLAUDE.md` and read your hard rules yourself once. If one is missing, add it now.

### If something goes wrong

- **No Spark icon:** it only shows when a file is open. Also: VS Code 1.94.0 or later, reload the window ("Developer: Reload Window"), and the folder must not be open in Restricted Mode. Source: https://code.claude.com/docs/en/vs-code#spark-icon-not-visible
- **The extension won't install:** check your VS Code version and install straight from the Marketplace: https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code
- **`claude` not found in the VS Code terminal:** the extension ships its own copy but does not put `claude` on your path. For the terminal you need the install from episode 1.
- **Claude can't find the blueprint folder:** tell it directly: `My blueprint folder is at ~/ailoopwise-blueprint/blueprint/` (from `Install-guide.md`, troubleshooting).
