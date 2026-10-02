# Fortsetzungs-Prompt (Folge 6)

**Deutsch** · [English](#english)

Füge diesen Text am Ende einer Session ein, **bevor** du `/clear` tippst. Claude sichert den Stand in den drei Aufgabendateien und gibt dir einen kurzen Prompt für die nächste Session zurück.

```text
Wir beenden diese Session. Bevor ich /clear eingebe:
1. Aktualisiere tasks/current.md: Status, getroffene Entscheidungen, geänderte Dateien, und unter "Exact Next Action" den nächsten Schritt so genau, dass eine frische Session ohne Rückfragen weitermachen kann (Dateipfade, Funktionsnamen, erwartetes Ergebnis).
2. Trag in tasks/lessons.md jede Regel ein, die wir heute aus einem Fehler gelernt haben, im Format "Tu X / Tu nie Y ... — gelernt nach ...". Gab es keine, schreib nichts.
3. Hake in tasks/todo.md nur ab, was fertig UND geprüft ist.
4. Sag mir, welche Tests, Lint- und Build-Befehle du in dieser Session wirklich ausgeführt hast und mit welchem Ergebnis. Was du nicht ausgeführt hast, nennst du ausdrücklich.
5. Gib mir zum Schluss einen Fortsetzungs-Prompt in einem Codeblock, höchstens zehn Zeilen. Er beginnt mit "Lies tasks/current.md, tasks/lessons.md und tasks/todo.md." und beschreibt dann genau den nächsten Schritt.
```

Danach: Fortsetzungs-Prompt kopieren → `/clear` → Prompt einfügen → Enter.

So sieht ein Ergebnis aus Schritt 5 aus (Beispiel aus dem Newsletter-Projekt in `PRD-EXAMPLE-newsletter-tool.md`):

```text
Lies tasks/current.md, tasks/lessons.md und tasks/todo.md.
Nächster Schritt: Abmelde-Link bauen (todo.md, Aufgabe 4).
- Route GET /unsubscribe?token=... in src/routes/unsubscribe.ts
- Token-Prüfung wie in src/lib/tokens.ts (verifyToken)
- Danach Abonnent auf status "unsubscribed" setzen, nicht löschen
Fertig, wenn der neue Test in tests/unsubscribe.test.ts grün ist und npm test komplett durchläuft.
```

---

## English

Paste this at the end of a session, **before** you type `/clear`. Claude saves the state into the three task files and hands you a short prompt for the next session.

```text
We are ending this session. Before I type /clear:
1. Update tasks/current.md: status, decisions made, files changed, and under "Exact Next Action" the next step, precise enough that a fresh session can continue without asking me anything (file paths, function names, expected result).
2. Add to tasks/lessons.md every rule we learned from a mistake today, in the format "Do X / Don't do Y ... — learned after ...". If there were none, write nothing.
3. In tasks/todo.md, tick off only what is finished AND checked.
4. Tell me which test, lint and build commands you actually ran in this session and what the result was. Name explicitly anything you did not run.
5. Finally, give me a continuation prompt in a code block, ten lines at most. It starts with "Read tasks/current.md, tasks/lessons.md and tasks/todo.md." and then describes exactly the next step.
```

Then: copy the continuation prompt → `/clear` → paste the prompt → Enter.

A result from step 5 looks like this (example from the newsletter project in `PRD-EXAMPLE-newsletter-tool.md`):

```text
Read tasks/current.md, tasks/lessons.md and tasks/todo.md.
Next step: build the unsubscribe link (todo.md, task 4).
- Route GET /unsubscribe?token=... in src/routes/unsubscribe.ts
- Token check as in src/lib/tokens.ts (verifyToken)
- Then set the subscriber to status "unsubscribed", do not delete
Done when the new test in tests/unsubscribe.test.ts passes and npm test runs clean.
```
