# Folge 5 · Projektstart per Sprache (vom Sprachchat zum PRD)

**Deutsch** · [English](#english) · [Übersicht](README.md) · Zurück: [Folge 4](04-guardrails.md) · Weiter: [Folge 6](06-long-sessions.md)

Große Projekte starten nicht im Editor, sondern bei der Idee. Dafür nimmst du die normale Claude-App auf dem Handy, brainstormst die Logik im Sprachchat und lässt dir am Ende einen strukturierten Bauplan ausgeben: ein PRD (Product Requirements Document), also was gebaut wird, für wen und woran man erkennt, dass es fertig ist. Erst danach wechselst du in die Entwicklungsumgebung, springst in einen neuen Ordner und gibst Claude Code mit `/new-project` den Bauplan. Die Ordnerstruktur steht in Sekunden.

Die Wand: Ein gutes PRD zu schreiben ist schwerer, als es klingt. Ein schlechtes baut die KI genauso.

## Was du am Ende hast

- Ein PRD für dein Projekt, im Sprachchat entstanden, gespeichert als `PRD.md`.
- Einen Projektordner, den `/new-project` aus diesem PRD eingerichtet hat: `.claude/CLAUDE.md` mit deinen festen Regeln, `tasks/todo.md` mit den Funktionen als Aufgaben.

## Was du brauchst

- **Die Claude-App** auf dem Handy: https://claude.ai/download
- **Sprachmodus** (alle Pläne, am besten auf dem Handy): https://support.claude.com/en/articles/11101966-use-voice-mode
- **Den Brainstorming-Prompt:** [examples/prompt-prd-brainstorm.md](examples/prompt-prd-brainstorm.md) und die **PRD-Vorlage:** [examples/PRD-TEMPLATE.md](examples/PRD-TEMPLATE.md)
- **Diktieren in Claude Code** (optional): https://code.claude.com/docs/de/voice-dictation
- Dein Setup aus Folge 2, oder den Server aus Folge 3

## Schritt für Schritt

1. **Einmalig: `/new-project` überall verfügbar machen** (nur dieser eine Skill; die vollständige globale Installation steht in `Install-guide.md`, Teil 1; macOS, Linux, WSL):
   ```bash
   mkdir -p ~/.claude/skills
   cp -r ~/ailoopwise-blueprint/blueprint/skills/new-project/ ~/.claude/skills/new-project/
   ```
2. **Sprache einstellen:** In der Claude-App unter **Settings → General → Voice → Language** Deutsch wählen. Die Anzeigesprache der App ändert die Sprache des Sprachmodus nicht.
3. **Neuer Chat, Prompt einfügen:** Kopiere den Brainstorming-Prompt aus [examples/prompt-prd-brainstorm.md](examples/prompt-prd-brainstorm.md) als erste Nachricht und schick ihn ab.
4. **Sprachmodus starten:** Tippe im Eingabefeld auf das Schallwellen-Symbol neben dem Mikrofon und rede. Claude fragt, du antwortest. Sag „fertig“, wenn alles gesagt ist. Das Transkript bleibt im Chat.
5. **PRD abholen:** Sprachmodus beenden und schreiben:
   ```text
   Gib mir das PRD jetzt als einen einzigen Markdown-Codeblock.
   ```
   Kopiere den Block. Lies ihn einmal: Alles, was du nicht gesagt hast, gehört unter „Offene Fragen“.
6. **Ordner anlegen und PRD speichern:**
   ```bash
   mkdir ~/mein-projekt
   ```
   Öffne den Ordner in VS Code, lege `PRD.md` an und füge den Block ein. Auf dem Server aus Folge 3 schickst du dir den Text und legst die Datei dort an.
7. **Claude Code im neuen Ordner starten** (VS Code: Claude-Panel öffnen; Terminal: `cd ~/mein-projekt` und `claude`).
8. **Diktieren einschalten** (optional): Im Terminal `/voice`, dann Leertaste halten und sprechen. Die VS-Code-Erweiterung kann das auch. Über SSH geht es nicht; dort nimmst du die Diktierfunktion deiner Handy-Tastatur.
9. **Den Bauplan übergeben**, gesprochen oder getippt:
   ```text
   /new-project Lies PRD.md in diesem Ordner. Nimm daraus Projektname, Bereich, Beschreibung und Technik und richte das Projekt in DIESEM Ordner ein. Schreib den Abschnitt "Regeln, die die KI nie brechen darf" als feste Regeln in .claude/CLAUDE.md und die Funktionen als nummerierte Aufgaben mit Abnahmekriterium in tasks/todo.md. Frag nur nach, was im PRD fehlt.
   ```
10. **Prüfen:** `.claude/CLAUDE.md` enthält deine Regeln, `tasks/todo.md` deine Funktionen, `tasks/current.md` den ersten Schritt.

## Beispiel zum Kopieren

Die leere Vorlage: [examples/PRD-TEMPLATE.md](examples/PRD-TEMPLATE.md). Ein ausgefülltes Beispiel für ein kleines Newsletter-Tool: [examples/PRD-EXAMPLE-newsletter-tool.md](examples/PRD-EXAMPLE-newsletter-tool.md). Der Teil, aus dem später Aufgaben werden:

```markdown
| # | Funktion | Abnahmekriterium |
|---|----------|------------------|
| 3 | Versand | `npm run send -- rundbrief.md --test` geht nur an die Vorstandsadresse; ohne `--test` an alle bestätigten Abonnenten |
| 4 | Abmeldung | Link in jeder Mail setzt "unsubscribed"; die Adresse bekommt keine weitere Mail |
```

Jede Funktion hat ein prüfbares Abnahmekriterium. Fehlt es, weiß die KI nicht, wann sie fertig ist.

## Bevor du zur nächsten Folge gehst

Sprich das PRD für dein eigenes Projekt ein und speichere es als `PRD.md` in einem neuen Ordner.

## Wenn etwas hakt

- **`/new-project` ist unbekannt:** Der Skill liegt nicht unter `~/.claude/skills/new-project/SKILL.md`, oder der Ordner `~/.claude/skills` existierte beim Start der Session noch nicht. Schritt 1 prüfen, dann Claude Code neu starten. Quelle: https://code.claude.com/docs/de/skills#live-change-detection
- **`/voice` funktioniert nicht:** Diktieren braucht ein claude.ai-Konto und ein Mikrofon am selben Gerät; in SSH-Sitzungen geht es nicht. Quelle: https://code.claude.com/docs/de/voice-dictation#requirements
- **Der Sprachmodus versteht dich schlecht oder antwortet in der falschen Sprache:** Stell die Voice-Sprache unter **Settings → General → Voice → Language** ein (Schritt 2). Andere Sprachen als Englisch sind laut Hilfe-Center noch Beta. Quelle: https://support.claude.com/en/articles/11101966-use-voice-mode

---

## English

[Overview](README.md) · Back: [Episode 4](04-guardrails.md) · Next: [Episode 6](06-long-sessions.md)

Big projects don't start in the editor, they start with the idea. For that you use the normal Claude app on your phone, brainstorm the logic by voice and have it write a structured blueprint at the end: a PRD (product requirements document), meaning what gets built, for whom, and how you'll know it's done. Only then do you move into the dev environment, jump into a new folder and hand Claude Code the blueprint with `/new-project`. The folder structure is there in seconds.

The wall: writing a good PRD is harder than it sounds. The AI will happily build a bad one.

### What you'll have at the end

- A PRD for your project, made in a voice chat, saved as `PRD.md`.
- A project folder that `/new-project` set up from that PRD: `.claude/CLAUDE.md` with your hard rules, `tasks/todo.md` with the features as tasks.

### What you need

- **The Claude app** on your phone: https://claude.ai/download
- **Voice mode** (all plans, works best on the phone): https://support.claude.com/en/articles/11101966-use-voice-mode
- **The brainstorming prompt:** [examples/prompt-prd-brainstorm.md](examples/prompt-prd-brainstorm.md) and the **PRD template:** [examples/PRD-TEMPLATE.md](examples/PRD-TEMPLATE.md)
- **Dictation in Claude Code** (optional): https://code.claude.com/docs/en/voice-dictation
- Your setup from episode 2, or the server from episode 3

### Step by step

1. **Once: make `/new-project` available everywhere** (this one skill only; the full global install is `Install-guide.md`, Part 1; macOS, Linux, WSL):
   ```bash
   mkdir -p ~/.claude/skills
   cp -r ~/ailoopwise-blueprint/blueprint/skills/new-project/ ~/.claude/skills/new-project/
   ```
2. **Set the language:** in the Claude app under **Settings → General → Voice → Language**, pick the language you'll speak. The app's display language does not change the voice language.
3. **New chat, paste the prompt:** copy the brainstorming prompt from [examples/prompt-prd-brainstorm.md](examples/prompt-prd-brainstorm.md) as the first message and send it.
4. **Start voice mode:** tap the sound-wave icon next to the microphone in the input field and talk. Claude asks, you answer. Say "done" when everything is said. The transcript stays in the chat.
5. **Collect the PRD:** leave voice mode and type:
   ```text
   Give me the PRD now as one single Markdown code block.
   ```
   Copy the block. Read it once: anything you did not say belongs under "Open questions".
6. **Create the folder and save the PRD:**
   ```bash
   mkdir ~/my-project
   ```
   Open the folder in VS Code, create `PRD.md` and paste the block. On the server from episode 3, send yourself the text and create the file there.
7. **Start Claude Code in the new folder** (VS Code: open the Claude panel; terminal: `cd ~/my-project` and `claude`).
8. **Turn on dictation** (optional): in the terminal `/voice`, then hold the space bar and speak. The VS Code extension can do this too. It doesn't work over SSH; there you use your phone keyboard's dictation.
9. **Hand over the blueprint**, spoken or typed:
   ```text
   /new-project Read PRD.md in this folder. Take the project name, domain, description and tech from it and set up the project in THIS folder. Write the section "Rules the AI must never break" into .claude/CLAUDE.md as hard rules, and the features as numbered tasks with acceptance criteria into tasks/todo.md. Only ask about what the PRD is missing.
   ```
10. **Check:** `.claude/CLAUDE.md` holds your rules, `tasks/todo.md` your features, `tasks/current.md` the first step.

### Example to copy

The blank template: [examples/PRD-TEMPLATE.md](examples/PRD-TEMPLATE.md). A filled example for a small newsletter tool (in German): [examples/PRD-EXAMPLE-newsletter-tool.md](examples/PRD-EXAMPLE-newsletter-tool.md). The part that later turns into tasks:

```markdown
| # | Feature | Acceptance criterion |
|---|---------|----------------------|
| 3 | Sending | `npm run send -- newsletter.md --test` only goes to the board address; without `--test` to all confirmed subscribers |
| 4 | Unsubscribe | The link in every mail sets "unsubscribed"; the address gets no further mail |
```

Every feature has a checkable acceptance criterion. Without one, the AI doesn't know when it's done.

### Before the next episode

Speak the PRD for your own project and save it as `PRD.md` in a new folder.

### If something goes wrong

- **`/new-project` is unknown:** the skill isn't at `~/.claude/skills/new-project/SKILL.md`, or the `~/.claude/skills` folder didn't exist when the session started. Check step 1, then restart Claude Code. Source: https://code.claude.com/docs/en/skills#live-change-detection
- **`/voice` doesn't work:** dictation needs a claude.ai account and a microphone on the same machine; it doesn't work in SSH sessions. Source: https://code.claude.com/docs/en/voice-dictation#requirements
- **Voice mode misunderstands you or answers in the wrong language:** set the voice language under **Settings → General → Voice → Language** (step 2). Languages other than English are still beta per the help centre. Source: https://support.claude.com/en/articles/11101966-use-voice-mode
