# Folge 6 · Lange Sitzungen (Unter-Agenten, Fortsetzungs-Prompt, /clear)

**Deutsch** · [English](#english) · [Übersicht](README.md) · Zurück: [Folge 5](05-voice-kickoff-prd.md)

**In dieser Folge (≈ 20 Min.):**

- Einen festen Rhythmus: eine Aufgabe pro Session, dann `/clear`.
- Unter-Agenten für Recherche und einen Reviewer, der deine Änderungen prüft.
- Einen Fortsetzungs-Prompt, mit dem die nächste Session ohne Rückfragen weitermacht.

Wer stundenlang in derselben Session arbeitet, verbrennt Token, und die KI wird ungenauer. Die Doku sagt es direkt: „performance degrades as it fills“ ([Quelle](https://code.claude.com/docs/de/best-practices)). Besser sind kurze Zyklen: Aufwändige Teilaufgaben gehen an Unter-Agenten, am Ende prüft ein unabhängiger Reviewer-Agent, dann lässt du dir einen Fortsetzungs-Prompt geben und löschst mit `/clear` den Verlauf. Das Wissen steckt in deinen Textdateien. Die frische Session bekommt den neuen Prompt und arbeitet ohne Altlasten weiter.

Die Wand: Der Workflow sitzt erst nach ein paar Wochen. Bis dahin verlierst du Sessions.

## Was du am Ende hast

- Einen festen Rhythmus: eine Aufgabe pro Session, Recherche beim Unter-Agenten, Prüfung durch den Reviewer, Fortsetzungs-Prompt, `/clear`.
- Aufgabendateien, die nach jeder Session den echten Stand zeigen.

## Was du brauchst

- Dein Projekt mit den Agenten aus dem Blueprint: `/new-project` legt `researcher`, `implementer` und `reviewer` unter `.claude/agents/` an.
- **Den Fortsetzungs-Prompt:** [examples/prompt-continuation.md](examples/prompt-continuation.md)
- Zum Nachlesen: Unter-Agenten https://code.claude.com/docs/de/sub-agents · Kontextfenster https://code.claude.com/docs/de/context-window · Kosten senken https://code.claude.com/docs/de/costs

## Schritt für Schritt

1. **Kontext ansehen.** Tippe irgendwann in der Session:
   ```text
   /context
   ```
   Du siehst, was wie viel Platz belegt, inklusive deiner CLAUDE.md.
2. **Eine Aufgabe pro Session.** Starte mit dem Fortsetzungs-Prompt der letzten Session oder mit:
   ```text
   Read tasks/current.md and tasks/lessons.md. Summarize where we left off.
   ```
3. **Recherche auslagern.** Tippe `@` und wähle `researcher (agent)`, oder schreib den Namen direkt:
   ```text
   @agent-researcher Finde heraus, wie man in Node.js signierte Abmelde-Links baut, ohne Tokens in der Datenbank zu speichern. Gib mir nur eine Zusammenfassung mit Quellen zurück, höchstens zehn Zeilen.
   ```
   Der Unter-Agent arbeitet in seinem eigenen Kontextfenster. Zurück kommt nur die Zusammenfassung, dein Hauptfenster bleibt frei.
4. **Arbeiten.** Claude setzt die Aufgabe um und prüft sie (Folge 4: frag nach dem Testlauf).
5. **Unabhängig prüfen lassen:**
   ```text
   @agent-reviewer Prüfe alle Änderungen dieser Session (git diff). Kritische Fehler zuerst, mit Datei und Zeile. Ändere nichts.
   ```
   Der Reviewer aus dem Blueprint hat kein Edit- oder Write-Werkzeug und ist angewiesen, nichts zu ändern. Was er findet, behebst du in der Hauptsession.
6. **Stand sichern:** Füge den Fortsetzungs-Prompt aus [examples/prompt-continuation.md](examples/prompt-continuation.md) ein. Claude aktualisiert `current.md`, `lessons.md` und `todo.md` und gibt dir einen kurzen Prompt zurück.
7. **Kopieren, leeren, weiter:** Kopiere den Prompt, dann:
   ```text
   /clear
   ```
   Füge den Prompt ein und drücke Enter. `/clear` kostet nichts; `/compact` dagegen fasst den Verlauf zusammen und ist selbst eine große Anfrage ([Quelle](https://code.claude.com/docs/de/costs)).

## Beispiel zum Kopieren

Der Fortsetzungs-Prompt steht vollständig unten unter „Sag deiner KI“, mit einem Beispielergebnis in [examples/prompt-continuation.md](examples/prompt-continuation.md).

## Bevor du zur nächsten Folge gehst

Es gibt keine nächste Folge. Beende deine nächste Session mit dem Fortsetzungs-Prompt und `/clear`, und starte die neue mit dem, was Claude dir zurückgegeben hat.

## Wenn etwas hakt

- **Du korrigierst Claude zum dritten Mal beim selben Problem:** Der Kontext ist voll mit gescheiterten Versuchen. `/clear` und mit einem genaueren Prompt neu anfangen, der das Gelernte enthält. Quelle: https://code.claude.com/docs/de/best-practices
- **Nach `/clear` fehlt dir etwas aus dem alten Gespräch:** Mit `/resume` holst du es zurück. Tipp: vorher `/rename` vergeben, dann findest du es leichter. Quelle: https://code.claude.com/docs/de/commands
- **Claude recherchiert selbst, statt den Unter-Agenten zu nehmen:** Nur beim Namen nennen ist ein Vorschlag. Die @-Erwähnung (`@agent-researcher`) sorgt dafür, dass genau dieser Agent läuft. Quelle: https://code.claude.com/docs/de/sub-agents#invoke-subagents-explicitly
- **In einer sehr langen Session vergisst Claude frühe Anweisungen:** Beim automatischen Zusammenfassen können Details vom Anfang verloren gehen. Dauerhafte Regeln gehören in die CLAUDE.md, nicht in den Chat. Quelle: https://code.claude.com/docs/de/how-claude-code-works

## Sag deiner KI

Füge das am Ende einer Session ein, **bevor** du `/clear` tippst. Claude sichert den Stand in den drei Aufgabendateien und gibt dir einen kurzen Prompt für die nächste Session zurück.

```text
Wir beenden diese Session. Bevor ich /clear eingebe:
1. Aktualisiere tasks/current.md: Status, getroffene Entscheidungen, geänderte Dateien, und unter "Exact Next Action" den nächsten Schritt so genau, dass eine frische Session ohne Rückfragen weitermachen kann (Dateipfade, Funktionsnamen, erwartetes Ergebnis).
2. Trag in tasks/lessons.md jede Regel ein, die wir heute aus einem Fehler gelernt haben, im Format "Tu X / Tu nie Y ... — gelernt nach ...". Gab es keine, schreib nichts.
3. Hake in tasks/todo.md nur ab, was fertig UND geprüft ist.
4. Sag mir, welche Tests, Lint- und Build-Befehle du in dieser Session wirklich ausgeführt hast und mit welchem Ergebnis. Was du nicht ausgeführt hast, nennst du ausdrücklich.
5. Gib mir zum Schluss einen Fortsetzungs-Prompt in einem Codeblock, höchstens zehn Zeilen. Er beginnt mit "Lies tasks/current.md, tasks/lessons.md und tasks/todo.md." und beschreibt dann genau den nächsten Schritt.
```

---

## English

[Overview](README.md) · Back: [Episode 5](05-voice-kickoff-prd.md)

**In this episode (≈ 20 min):**

- A fixed rhythm: one task per session, then `/clear`.
- Subagents for research and a reviewer that checks your changes.
- A continuation prompt so the next session continues without questions.

Working for hours in the same session burns tokens, and the AI gets less precise. The docs say it plainly: "performance degrades as it fills" ([source](https://code.claude.com/docs/en/best-practices)). Short cycles work better: heavy sub-tasks go to subagents, a separate reviewer agent checks at the end, then you have Claude write a continuation prompt and wipe the history with `/clear`. The knowledge lives in your text files. The fresh session gets the new prompt and carries on with no baggage.

The wall: the workflow only clicks after a few weeks. Until then you'll lose sessions.

### What you'll have at the end

- A fixed rhythm: one task per session, research with a subagent, review by the reviewer, continuation prompt, `/clear`.
- Task files that show the real state after every session.

### What you need

- Your project with the blueprint's agents: `/new-project` creates `researcher`, `implementer` and `reviewer` in `.claude/agents/`.
- **The continuation prompt:** [examples/prompt-continuation.md](examples/prompt-continuation.md)
- For reference: subagents https://code.claude.com/docs/en/sub-agents · context window https://code.claude.com/docs/en/context-window · reducing cost https://code.claude.com/docs/en/costs

### Step by step

1. **Look at your context.** At any point in the session type:
   ```text
   /context
   ```
   You see what takes how much space, including your CLAUDE.md.
2. **One task per session.** Start with the last session's continuation prompt, or with:
   ```text
   Read tasks/current.md and tasks/lessons.md. Summarize where we left off.
   ```
3. **Offload research.** Type `@` and pick `researcher (agent)`, or write the name directly:
   ```text
   @agent-researcher Find out how to build signed unsubscribe links in Node.js without storing tokens in the database. Return only a summary with sources, ten lines at most.
   ```
   The subagent works in its own context window. Only the summary comes back, and your main window stays free.
4. **Do the work.** Claude implements the task and checks it (episode 4: ask for the test run).
5. **Have it checked independently:**
   ```text
   @agent-reviewer Review every change from this session (git diff). Critical issues first, with file and line. Do not change anything.
   ```
   The blueprint's reviewer has no Edit or Write tool and is instructed not to change anything. You fix what it finds in the main session.
6. **Save the state:** paste the continuation prompt from [examples/prompt-continuation.md](examples/prompt-continuation.md). Claude updates `current.md`, `lessons.md` and `todo.md` and hands you a short prompt.
7. **Copy, clear, continue:** copy the prompt, then:
   ```text
   /clear
   ```
   Paste the prompt and press Enter. `/clear` costs nothing; `/compact`, by contrast, summarises the history and is itself a large request ([source](https://code.claude.com/docs/en/costs)).

### Example to copy

The full continuation prompt is below under "Tell your AI", with an example result in [examples/prompt-continuation.md](examples/prompt-continuation.md).

### Before the next episode

There is no next episode. End your next session with the continuation prompt and `/clear`, and start the new one with what Claude handed you.

### If something goes wrong

- **You're correcting Claude for the third time on the same problem:** the context is full of failed attempts. `/clear` and start again with a sharper prompt that includes what you learned. Source: https://code.claude.com/docs/en/best-practices
- **After `/clear` you're missing something from the old conversation:** `/resume` brings it back. Tip: give it a name with `/rename` first so it's easier to find. Source: https://code.claude.com/docs/en/commands
- **Claude researches itself instead of using the subagent:** naming it is a suggestion. The @-mention (`@agent-researcher`) makes sure exactly that agent runs. Source: https://code.claude.com/docs/en/sub-agents#invoke-subagents-explicitly
- **In a very long session Claude forgets early instructions:** automatic summarising can drop details from the start. Permanent rules belong in CLAUDE.md, not in the chat. Source: https://code.claude.com/docs/en/how-claude-code-works

### Tell your AI

Paste this at the end of a session, **before** you type `/clear`. Claude saves the state into the three task files and hands you a short prompt for the next session.

```text
We are ending this session. Before I type /clear:
1. Update tasks/current.md: status, decisions made, files changed, and under "Exact Next Action" the next step, precise enough that a fresh session can continue without asking me anything (file paths, function names, expected result).
2. Add to tasks/lessons.md every rule we learned from a mistake today, in the format "Do X / Don't do Y ... — learned after ...". If there were none, write nothing.
3. In tasks/todo.md, tick off only what is finished AND checked.
4. Tell me which test, lint and build commands you actually ran in this session and what the result was. Name explicitly anything you did not run.
5. Finally, give me a continuation prompt in a code block, ten lines at most. It starts with "Read tasks/current.md, tasks/lessons.md and tasks/todo.md." and then describes exactly the next step.
```
