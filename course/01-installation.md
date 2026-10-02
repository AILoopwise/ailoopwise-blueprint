# Folge 1 · Installation

**Deutsch** · [English](#english) · [Übersicht](README.md) · Weiter: [Folge 2](02-desktop-setup.md)

**In dieser Folge (≈ 20 Min.):**

- Claude Code läuft auf deinem Rechner, angemeldet mit deinem Konto.
- Deine erste Session in einem leeren Übungsordner.
- Das Setup-Paket liegt bereit unter `~/ailoopwise-blueprint`.

Prompts in einen Browser-Tab zu tippen stößt bei echten Projekten schnell an Grenzen. Mit diesem Setup haben wir die Plattform für liveinthemovent.com entwickelt, über die mittlerweile über 8.000 Ticketverkäufe laufen: iOS- und Android-Apps, Ticketscanner für den Einlass, Marketing im Hintergrund. Die KI schreibt nicht alles beim ersten Versuch richtig. Mit Leitplanken spart sie trotzdem sehr viel Zeit. In sechs Folgen gehst du vom leeren Ordner zu einem System, das deine Regeln kennt und Aufgaben allein erledigt. Folge 3 (Server) ist optional.

Ehrlich vorweg: Die erste App baust du an einem Abend. Sie am Laufen zu halten ist der eigentliche Job.

## Was du am Ende hast

- Claude Code ist installiert, `claude --version` zeigt eine Versionsnummer.
- Du hast dich einmal mit deinem Claude-Konto angemeldet.
- Du hattest eine erste Session in einem leeren Ordner.
- Das Setup-Paket liegt unter `~/ailoopwise-blueprint` bereit für Folge 2.

## Was du brauchst

- **Ein bezahltes Claude-Abo** (Pro, Max, Team oder Enterprise) oder ein Console-Konto. Der kostenlose Plan enthält Claude Code nicht. Quelle: https://code.claude.com/docs/de/setup#authenticate
- **Einen Rechner**, der die Systemanforderungen erfüllt (macOS 13+, Windows 10 1809+, Ubuntu 20.04+, 4 GB RAM): https://code.claude.com/docs/de/setup
- **Ein Terminal.** Noch nie benutzt? https://code.claude.com/docs/de/terminal-guide
- **Git**, das brauchst du spätestens in Folge 4: https://git-scm.com/downloads
- **jq**, damit die Schutz-Hooks aus Folge 4 laufen: https://jqlang.org/download/
- **Das Setup-Paket** (gratis): https://www.ailoopwise.com/de/starter

## Schritt für Schritt

1. Öffne die offizielle Installationsseite: https://code.claude.com/docs/de/setup
   Kopiere den Befehl für dein System **von dort**, nicht aus einem Video oder von hier. Die Methode ändert sich von Zeit zu Zeit.
2. Prüfe die Installation:
   ```bash
   claude --version
   ```
   Du siehst eine Versionsnummer. Für eine ausführlichere Prüfung:
   ```bash
   claude doctor
   ```
3. Lege einen leeren Übungsordner an und starte Claude Code darin:
   ```bash
   mkdir erste-session
   cd erste-session
   claude
   ```
4. Beim ersten Start öffnet sich der Browser. Melde dich mit deinem Claude-Konto an und bestätige.
5. Gib deinen ersten Prompt ein:
   ```text
   Erkläre mir in drei kurzen Sätzen, was du in diesem Ordner tun kannst und was nicht. Lege noch keine Dateien an.
   ```
6. Beende die Session mit `/exit`.
7. Lade das Setup-Paket herunter, entpacke es und lege den Ordner mit genau diesem Namen in deinen Benutzerordner: `~/ailoopwise-blueprint`. Die Skripte erwarten ihn dort.

## Beispiel zum Kopieren

So sieht die Projektdatei aus, die du am Ende von Folge 2 hast: [examples/CLAUDE-example.md](examples/CLAUDE-example.md). Der wichtigste Teil sind die festen Regeln:

```markdown
## Hard rules (the AI must never)
- Send to real subscribers. Every send command you run uses --test.
- Write the mail API key into code, tests or git. It lives only in .env.
```

## Bevor du zur nächsten Folge gehst

Tippe `claude --version` in ein neues Terminalfenster. Erscheint eine Versionsnummer, bist du bereit.

## Wenn etwas hakt

- **`command not found: claude` (oder „nicht erkannt“ unter Windows):** Das Installationsverzeichnis fehlt im Suchpfad deiner Shell. Lösung je System: https://code.claude.com/docs/de/troubleshoot-install#verify-your-path
- **Windows meldet `'irm' is not recognized` oder `The token '&&' is not a valid statement separator`:** Du hast den Befehl für die andere Shell kopiert (PowerShell vs. CMD). Nimm auf der Setup-Seite den Befehl für die Shell, in der du gerade bist.
- **`403 Forbidden` nach dem Login:** Prüfe unter https://claude.ai/settings, ob dein Abo aktiv ist. Mit dem Gratis-Plan geht es nicht.
- **Der Browser öffnet sich nicht oder der Code wird als ungültig abgelehnt:** Drücke beim Login `c`, um die Anmelde-URL zu kopieren, öffne sie selbst im Browser und schließe den Login zügig ab.

## Sag deiner KI

Wenn alle Schritte erledigt sind, starte `claude` noch einmal im Ordner `erste-session` und füge das ein:

```text
Ich habe gerade Claude Code installiert und bin kein Entwickler. Prüf mein Setup und erkläre alles in einfachen Worten.
1. Führ claude --version, git --version und jq --version aus und sag mir, was jedes Ergebnis bedeutet. Installier nichts selbst. Fehlt etwas, sag es mir, und ich installiere es über den Link in der Anleitung.
2. Prüf, ob es den Ordner ~/ailoopwise-blueprint gibt und ob darin blueprint/MASTER-BLUEPRINT.md liegt. Wenn nicht, sag mir, was ich korrigieren muss. Verschieb und lade nichts selbst.
3. Lies ~/ailoopwise-blueprint/course/examples/CLAUDE-example.md und erkläre mir den Abschnitt "Hard rules" in drei kurzen Zeilen.
4. In dieser Session liest du nur. Leg keine Datei an und ändere oder lösche nichts, weder in diesem Ordner noch außerhalb.
5. Führ nie git commit oder git push aus, ohne dass ich darum bitte, und zeig nie ein Passwort, einen Schlüssel oder ein Token an.
```

---

## English

[Overview](README.md) · Next: [Episode 2](02-desktop-setup.md)

**In this episode (≈ 20 min):**

- Claude Code runs on your computer, signed in to your account.
- Your first session in an empty practice folder.
- The setup pack ready in `~/ailoopwise-blueprint`.

Typing prompts into a browser tab hits a wall fast when you're building something real. We built the platform for liveinthemovent.com with this setup, and it has handled more than 8,000 ticket sales: iOS and Android apps, ticket scanners for the door, marketing in the background. The AI doesn't get everything right first time. With guardrails it still saves you an enormous amount of time. Over six episodes you go from an empty folder to a system that knows your rules and does tasks on its own. Episode 3 (server) is optional.

Honest up front: you can build the first app in an evening. Keeping it running is the actual job.

### What you'll have at the end

- Claude Code is installed, `claude --version` prints a version number.
- You have signed in once with your Claude account.
- You had a first session in an empty folder.
- The setup pack sits in `~/ailoopwise-blueprint`, ready for episode 2.

### What you need

- **A paid Claude plan** (Pro, Max, Team or Enterprise) or a Console account. The free plan does not include Claude Code. Source: https://code.claude.com/docs/en/setup#authenticate
- **A computer** that meets the system requirements (macOS 13+, Windows 10 1809+, Ubuntu 20.04+, 4 GB RAM): https://code.claude.com/docs/en/setup
- **A terminal.** Never used one? https://code.claude.com/docs/en/terminal-guide
- **Git**, needed by episode 4 at the latest: https://git-scm.com/downloads
- **jq**, so the safety hooks from episode 4 can run: https://jqlang.org/download/
- **The setup pack** (free): https://www.ailoopwise.com/en/starter

### Step by step

1. Open the official install page: https://code.claude.com/docs/en/setup
   Copy the command for your system **from there**, not from a video or from here. The method changes from time to time.
2. Check the install:
   ```bash
   claude --version
   ```
   You see a version number. For a more detailed check:
   ```bash
   claude doctor
   ```
3. Create an empty practice folder and start Claude Code in it:
   ```bash
   mkdir first-session
   cd first-session
   claude
   ```
4. On first start your browser opens. Sign in with your Claude account and confirm.
5. Enter your first prompt:
   ```text
   Explain in three short sentences what you can and cannot do in this folder. Do not create any files yet.
   ```
6. End the session with `/exit`.
7. Download the setup pack, unzip it and put the folder in your home folder with exactly this name: `~/ailoopwise-blueprint`. The scripts expect it there.

### Example to copy

This is the project file you'll have at the end of episode 2: [examples/CLAUDE-example.md](examples/CLAUDE-example.md). The key part is the hard rules:

```markdown
## Hard rules (the AI must never)
- Send to real subscribers. Every send command you run uses --test.
- Write the mail API key into code, tests or git. It lives only in .env.
```

### Before the next episode

Type `claude --version` in a fresh terminal window. If a version number appears, you're ready.

### If something goes wrong

- **`command not found: claude` (or "not recognized" on Windows):** the install directory is not on your shell's search path. Fix per system: https://code.claude.com/docs/en/troubleshoot-install#verify-your-path
- **Windows says `'irm' is not recognized` or `The token '&&' is not a valid statement separator`:** you copied the command for the other shell (PowerShell vs CMD). Use the command on the setup page for the shell you're in.
- **`403 Forbidden` after login:** check at https://claude.ai/settings that your subscription is active. Claude Code isn't part of the free tier.
- **The browser doesn't open, or the code is rejected as invalid:** press `c` at the login prompt to copy the sign-in URL, open it yourself, and finish the login quickly.

### Tell your AI

When every step is done, start `claude` again in your `first-session` folder and paste this:

```text
I just installed Claude Code and I am not a developer. Check my setup and explain everything in plain words.
1. Run claude --version, git --version and jq --version and tell me what each result means. Install nothing yourself. If one is missing, tell me, and I will install it from the link in the guide.
2. Check that the folder ~/ailoopwise-blueprint exists and contains blueprint/MASTER-BLUEPRINT.md. If not, tell me what to fix. Do not move or download anything yourself.
3. Read ~/ailoopwise-blueprint/course/examples/CLAUDE-example.md and explain its "Hard rules" section in three short lines.
4. In this session you only read. Create no file and change or delete nothing, in this folder or outside it.
5. Never run git commit or git push unless I ask, and never print a password, key or token.
```
