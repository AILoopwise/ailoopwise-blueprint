# Folge 4 · Leitplanken (Hooks, Aufgabendateien, GitHub)

**Deutsch** · [English](#english) · [Übersicht](README.md) · Zurück: [Folge 3](03-server-optional.md) · Weiter: [Folge 5](05-voice-kickoff-prd.md)

Sobald dein Projekt mit dem Blueprint eingerichtet ist, arbeitet die KI in festen Leitplanken. Skripte (Hooks) laufen automatisch an festen Stellen, die KI kann sie nicht überspringen. Drei Textdateien halten den Kontext klein, damit eine frische Session in Sekunden weiß, wo ihr steht. Zum Schluss sicherst du alles in einem privaten GitHub-Repo.

Die Wand: Leitplanken schreiben ist die Arbeit, die keiner sieht. Bei uns waren es Monate.

## Was du am Ende hast

- Du weißt, welche Hooks wirklich blockieren und welche nur prüfen.
- Du hast einen Wächter absichtlich ausgelöst und gesehen, wie er blockiert.
- Du kennst die drei Aufgabendateien und startest jede Session damit.
- Dein Projekt liegt in einem privaten GitHub-Repo.

## Was du brauchst

- Dein Projekt aus [Folge 2](02-desktop-setup.md) (mit `.claude/hooks/` und `.claude/settings.json`)
- **jq**: Ohne jq blockieren die Schutz-Hooks Änderungen und Schreibzugriffe, bis es installiert ist (der Befehls-Wächter funktioniert trotzdem): https://jqlang.org/download/
- **Git:** https://git-scm.com/downloads · **ein GitHub-Konto:** https://github.com
- Zum Nachlesen: Hooks-Referenz https://code.claude.com/docs/de/hooks

## Was die Hooks tatsächlich tun

Die Skripte liegen in `blueprint/hooks/`, eingetragen in `.claude/settings.json`:

| Skript | Wann | Was es tut | Wirkung |
|---|---|---|---|
| `block-dangerous-commands.sh` | vor jedem Shell-Befehl | stoppt `rm -rf` auf Root-, Home- und Projektpfade, `git reset --hard`, `git clean -fd`, Force-Push, `git checkout`/`git restore` von Dateien, `DROP TABLE` & Co., Massenlöschen per `find`, Befehle, die Geheimnisse zeigen könnten (`cat .env`, `printenv`), `npm/yarn/pnpm publish` | **blockiert**, Claude sieht den Grund |
| `protect-sensitive-files.sh` | vor jedem Schreiben | sperrt `.env`-Dateien (Vorlagen wie `.env.example` erlaubt), Lockfiles, `.git/`, `node_modules/`, `.ssh/`, `.aws/`, `credentials`, `.pem`, `.key` | **blockiert** |
| `detect-secrets-in-code.sh` | vor jedem Schreiben | sucht AWS-, GitHub-, Stripe-, Slack- und `sk-`-Schlüssel, private Schlüssel, Datenbank-URLs mit Passwort (überspringt `.md`, Vorlagen, Test-Fixtures) | **blockiert** |
| `format-and-lint.sh` | nach jedem Schreiben von JS/TS | `eslint --fix`, wenn es ein `package.json` gibt | repariert still |
| `owasp-check.sh` | nach jedem Schreiben von Code | warnt bei SQL-Injection, `innerHTML`, `eval`, `shell=True` und Ähnlichem | nur Warnung |
| `audit-dependencies.sh` | nach `npm/pnpm/yarn/bun install` | führt den Sicherheits-Audit des Paketmanagers aus | nur Warnung |
| `quality-check.sh` | wenn Claude fertig ist | Typecheck, Lint, Format-Check und, wenn Code geändert wurde, Tests (JS/TS, Python, Go, Rust) | blockiert das Beenden einmal, wenn Typen oder Tests fehlschlagen; alles andere nur Warnung |
| `session-start.sh` | beim Session-Start | warnt, wenn jq fehlt, und verweist auf `tasks/current.md` und `tasks/lessons.md` | landet im Kontext |

**Ehrlich:** Die drei Wächter vor dem Schritt blockieren wirklich, und `quality-check.sh` blockiert das Beenden genau einmal, wenn Typecheck oder Tests fehlschlagen (Claude sieht den Grund und repariert; beim zweiten Versuch lässt es durch, damit nichts endlos hängt). Die übrigen Prüfungen enden mit Exit-Code 0, und laut Hooks-Referenz landet deren Ausgabe dann nur im Debug-Log: „Claude never sees it.“ Dass Claude nach jeder Aufgabe testet und Fehler selbst repariert, kommt aus der Regel „Mandatory Quality Checks“ in deiner CLAUDE.md. Die ist Kontext, keine Sperre. Die Doku sagt es so: Claude behandelt CLAUDE.md „as context, not enforced configuration“ ([Quelle](https://code.claude.com/docs/de/memory)). Frag also nach, welche Prüfung wirklich lief.

## Schritt für Schritt

1. Öffne dein Projekt und tippe `/hooks`. Du siehst die Einträge unter PreToolUse, PostToolUse, Stop und SessionStart mit der Quelle **Project Settings**.
2. Löse einen Wächter absichtlich aus:
   ```text
   Lege im Projektordner eine Datei .env mit dem Inhalt TEST=1 an.
   ```
   Erwartet: Claude meldet `BLOCKED: Protected file pattern` und legt nichts an. Liegt danach doch eine `.env` im Ordner, läuft der Wächter nicht: siehe „Wenn etwas hakt“. Lösch die Datei dann selbst.
3. Starte jede Session mit dem Satz aus `blueprint/MASTER-BLUEPRINT.md`:
   ```text
   Read tasks/current.md and tasks/lessons.md. Summarize where we left off.
   ```
   `current.md` ist der Ist-Zustand, `lessons.md` die gelernten Fehler, `todo.md` die nächsten Schritte.
4. Beende jede Aufgabe mit:
   ```text
   Welche Prüfungen (Typecheck, Lint, Tests, Build) hast du gerade ausgeführt? Nenne Befehl und Ergebnis. Was nicht lief, sag ausdrücklich.
   ```
5. Leg auf https://github.com/new ein **privates** Repo an, ohne README, Lizenz oder `.gitignore`.
6. Leg im Projekt eine `.gitignore` an. Die ersten drei Zeilen stammen aus `/new-project`, `.env` kommt dazu:
   ```text
   .claude/settings.local.json
   .mcp.json
   tasks/current.md
   .env
   ```
   Willst du deinen Arbeitsstand mit sichern, streich die Zeile `tasks/current.md`. `.mcp.json` und `.env` bleiben draußen, dort stehen Tokens.
7. Im Terminal des Projekts (in VS Code: `` Ctrl+` ``):
   ```bash
   git init -b main
   git add .
   git commit -m "Erstes Setup"
   git remote add origin <URL-DEINES-REPOS>
   git push -u origin main
   ```

## Beispiel zum Kopieren

Ausgefüllte Aufgabendateien für das Newsletter-Beispiel: [examples/current.md](examples/current.md) · [examples/lessons.md](examples/lessons.md) · [examples/todo.md](examples/todo.md). Der wichtigste Abschnitt ist „Exact Next Action“ in `current.md`:

```markdown
## Exact Next Action
Create src/routes/unsubscribe.ts with GET /unsubscribe?token=... . Verify the token with
verifyToken from src/lib/tokens.ts; on success set the subscriber's status to "unsubscribed"
[...] Done when npm test passes.
```

## Bevor du zur nächsten Folge gehst

Öffne dein Repo auf github.com und prüfe: Es ist privat, und `.mcp.json` und `.env` sind nicht dabei.

## Wenn etwas hakt

- **Die `.env` wurde angelegt, oder du siehst `Failed with non-blocking status code`:** Ein Hook konnte nicht starten, und dann läuft die Aktion einfach weiter. Prüfe, ob die Hooks in `~/.claude/hooks/` (oder `.claude/hooks/` im Projekt) liegen und in `~/.claude/settings.json` eingetragen sind; führe sonst `bootstrap.sh` erneut aus. Fehlt jq, siehst du stattdessen die Meldung „safety hooks need jq“, und die Änderung wird blockiert. Quelle: https://code.claude.com/docs/de/hooks#other-exit-codes
- **Claude sagt „Tests grün“, du hast keinen Lauf gesehen:** Nur Typ- und Testfehler blockieren; Lint- und Format-Warnungen von `quality-check.sh` stehen nur im Debug-Log. Starte mit `claude --debug` und lies `~/.claude/debug/<session-id>.txt`, oder lass Claude `npm test` sichtbar ausführen. Quelle: https://code.claude.com/docs/de/hooks#debug-hooks
- **`git push` fragt nach einem Passwort und scheitert:** GitHub nimmt keine Passwörter mehr. Gib ein Personal Access Token ein oder nutze den Git Credential Manager. Quelle: https://docs.github.com/de/get-started/git-basics/about-remote-repositories
- **`git push` wird abgelehnt (rejected):** Das Repo wurde auf GitHub mit README oder Lizenz angelegt. Leg es leer an. Quelle: https://docs.github.com/de/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github

---

## English

[Overview](README.md) · Back: [Episode 3](03-server-optional.md) · Next: [Episode 5](05-voice-kickoff-prd.md)

Once your project is set up with the blueprint, the AI works inside fixed guardrails. Scripts (hooks) run automatically at fixed points; the AI cannot skip them. Three text files keep the context small, so a fresh session knows where things stand within seconds. Finally you back everything up to a private GitHub repo.

The wall: writing the guardrails is the work nobody sees. For us it took months.

### What you'll have at the end

- You know which hooks really block and which only check.
- You triggered a guard on purpose and watched it block.
- You know the three task files and start every session with them.
- Your project sits in a private GitHub repo.

### What you need

- Your project from [episode 2](02-desktop-setup.md) (with `.claude/hooks/` and `.claude/settings.json`)
- **jq**: without it, the safety hooks block edits and writes until it is installed (the command guard still works): https://jqlang.org/download/
- **Git:** https://git-scm.com/downloads · **a GitHub account:** https://github.com
- For reference: hooks reference https://code.claude.com/docs/en/hooks

### What the hooks actually do

The scripts live in `blueprint/hooks/`, registered in `.claude/settings.json`:

| Script | When | What it does | Effect |
|---|---|---|---|
| `block-dangerous-commands.sh` | before every shell command | stops `rm -rf` on root, home and project paths, `git reset --hard`, `git clean -fd`, force push, `git checkout`/`git restore` of files, `DROP TABLE` and friends, mass deletion via `find`, commands that could expose secrets (`cat .env`, `printenv`), `npm/yarn/pnpm publish` | **blocks**, Claude sees why |
| `protect-sensitive-files.sh` | before every write | locks `.env` files (templates like `.env.example` allowed), lockfiles, `.git/`, `node_modules/`, `.ssh/`, `.aws/`, `credentials`, `.pem`, `.key` | **blocks** |
| `detect-secrets-in-code.sh` | before every write | looks for AWS, GitHub, Stripe, Slack and `sk-` keys, private keys, database URLs with passwords (skips `.md`, templates, test fixtures) | **blocks** |
| `format-and-lint.sh` | after every JS/TS write | `eslint --fix` if there is a `package.json` | fixes silently |
| `owasp-check.sh` | after every code write | warns on SQL injection, `innerHTML`, `eval`, `shell=True` and similar | warning only |
| `audit-dependencies.sh` | after `npm/pnpm/yarn/bun install` | runs the package manager's security audit | warning only |
| `quality-check.sh` | when Claude finishes | typecheck, lint, format check and, if code changed, tests (JS/TS, Python, Go, Rust) | blocks the stop once when types or tests fail; everything else is a warning only |
| `session-start.sh` | at session start | warns if jq is missing and points to `tasks/current.md` and `tasks/lessons.md` | goes into context |

**Honestly:** the three guards before the step really block, and `quality-check.sh` blocks the stop exactly once when the typecheck or the tests fail (Claude sees the reason and fixes it; the second attempt goes through so nothing hangs forever). The remaining checks exit with code 0, and per the hooks reference their output then goes to the debug log only: "Claude never sees it." That Claude tests after every task and fixes its own errors comes from the "Mandatory Quality Checks" rule in your CLAUDE.md. That is context, not a lock. The docs put it this way: Claude treats CLAUDE.md "as context, not enforced configuration" ([source](https://code.claude.com/docs/en/memory)). So ask which check actually ran.

### Step by step

1. Open your project and type `/hooks`. You see the entries under PreToolUse, PostToolUse, Stop and SessionStart with the source **Project Settings**.
2. Trigger a guard on purpose:
   ```text
   Create a file .env in the project folder containing TEST=1.
   ```
   Expected: Claude reports `BLOCKED: Protected file pattern` and creates nothing. If a `.env` shows up anyway, the guard isn't running: see "If something goes wrong". Delete the file yourself.
3. Start every session with the line from `blueprint/MASTER-BLUEPRINT.md`:
   ```text
   Read tasks/current.md and tasks/lessons.md. Summarize where we left off.
   ```
   `current.md` is where things stand, `lessons.md` the mistakes already made, `todo.md` what's next.
4. End every task with:
   ```text
   Which checks (typecheck, lint, tests, build) did you just run? Give the command and the result. Say explicitly what did not run.
   ```
5. Create a **private** repo at https://github.com/new, without README, licence or `.gitignore`.
6. Add a `.gitignore` to the project. The first three lines come from `/new-project`; `.env` is added:
   ```text
   .claude/settings.local.json
   .mcp.json
   tasks/current.md
   .env
   ```
   To back up your working state too, remove the `tasks/current.md` line. `.mcp.json` and `.env` stay out; tokens live there.
7. In the project terminal (`` Ctrl+` `` in VS Code):
   ```bash
   git init -b main
   git add .
   git commit -m "First setup"
   git remote add origin <YOUR-REPO-URL>
   git push -u origin main
   ```

### Example to copy

Filled task files for the newsletter example: [examples/current.md](examples/current.md) · [examples/lessons.md](examples/lessons.md) · [examples/todo.md](examples/todo.md). The key section is "Exact Next Action" in `current.md`:

```markdown
## Exact Next Action
Create src/routes/unsubscribe.ts with GET /unsubscribe?token=... . Verify the token with
verifyToken from src/lib/tokens.ts; on success set the subscriber's status to "unsubscribed"
[...] Done when npm test passes.
```

### Before the next episode

Open your repo on github.com and check: it is private, and `.mcp.json` and `.env` are not in it.

### If something goes wrong

- **The `.env` got created, or you see `Failed with non-blocking status code`:** a hook couldn't start, and then the action simply goes ahead. Check that the hooks are in `~/.claude/hooks/` (or `.claude/hooks/` in the project) and listed in `~/.claude/settings.json`; otherwise run `bootstrap.sh` again. If jq is missing you see "safety hooks need jq" instead, and the edit is blocked. Source: https://code.claude.com/docs/en/hooks#other-exit-codes
- **Claude says "tests pass" but you saw no run:** only type and test failures block; the lint and format warnings from `quality-check.sh` go to the debug log only. Start with `claude --debug` and read `~/.claude/debug/<session-id>.txt`, or have Claude run `npm test` visibly. Source: https://code.claude.com/docs/en/hooks#debug-hooks
- **`git push` asks for a password and fails:** GitHub no longer accepts passwords. Enter a personal access token or use Git Credential Manager. Source: https://docs.github.com/en/get-started/git-basics/about-remote-repositories
- **`git push` is rejected:** the repo was created on GitHub with a README or licence. Create it empty. Source: https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github
