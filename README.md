# AILoopwise Blueprint

**A ready-made setup for Claude Code, for people who are not developers.** It gives every project a rules file, a task memory that survives the night, ready-made skills and helper agents, and safety hooks that stop the AI from destroying your work.

[![install-test](https://github.com/AILoopwise/ailoopwise-blueprint/actions/workflows/install-test.yml/badge.svg)](https://github.com/AILoopwise/ailoopwise-blueprint/actions/workflows/install-test.yml)
[![release](https://img.shields.io/github/v/release/AILoopwise/ailoopwise-blueprint)](https://github.com/AILoopwise/ailoopwise-blueprint/releases/latest)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

English · [Deutsch](README.de.md)

## Why this exists

Claude Code is powerful, and it starts every session knowing nothing about your project. It forgets what it did yesterday, it does not know what it must never touch, and one wrong command can delete a folder or rewrite your git history.

This blueprint fixes that with plain files you can read:

| Problem | What the blueprint adds |
|---|---|
| The AI does not know your project | `CLAUDE.md`: what the project is, who it is for, and the rules it must follow |
| It forgets where it stopped | `tasks/current.md`, `tasks/lessons.md`, `tasks/todo.md`: written at the end of a session, read at the start of the next |
| You repeat the same instructions | Skills: reusable instructions for coding, design, marketing and sales work |
| One agent does everything | Three helper agents: a researcher, an implementer and a reviewer |
| A command can destroy work | Safety hooks that run before every command and block the dangerous ones |

## Quick start

1. **Install Claude Code** with [Anthropic's install guide](https://code.claude.com/docs/en/setup), and install [jq](https://jqlang.org/download/) (the safety hooks need it).
2. **Download** [ailoopwise-blueprint.zip](https://github.com/AILoopwise/ailoopwise-blueprint/releases/latest/download/ailoopwise-blueprint.zip), unzip it into your home folder as `~/ailoopwise-blueprint`, and open that folder in VS Code with the Claude Code extension.
3. **Paste one prompt** into Claude Code. It asks you three questions and builds your first project in a new folder:

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

On Windows, use WSL 2 or install [Git for Windows](https://git-scm.com/download/win) first: the safety hooks are Bash scripts and do not run without one of the two. Step-by-step pages for every part are in [`course/`](course/README.md).

## The safety guard

Before Claude Code runs a shell command, the guard reads it and decides. It is tuned to stop the commands that lose work, and to stay out of the way of normal work.

| Blocked | Allowed |
|---|---|
| `rm -rf ~`, `rm -rf .`, `rm -rf *` | `rm -rf node_modules dist .next` |
| `rm -rf .git` | `git restore --staged file.txt` |
| `git reset --hard`, `git clean -fdx` | `git clean -n` (dry run) |
| `git push --force` | `git push --force-with-lease` |
| `prisma migrate reset`, `docker compose down -v` | `docker compose down` |
| reading `.env` files | writing to `.env.local` |

- It looks inside chains, subshells, `bash -c "…"`, `$( … )`, `if`/`for` blocks and `git -C <folder>`.
- **If the check itself fails** (a crash, a timeout, input too large), the command is blocked, not waved through. The command guard also works without `jq`; the other safety hooks block edits until `jq` is installed.
- Its test matrix of 716 cases runs on every change, on Linux, macOS and Windows.
- Known limits are written at the top of [`block-dangerous-commands.sh`](blueprint/hooks/block-dangerous-commands.sh). It is a safety net, not a sandbox.

Other hooks scan edits for secrets, protect sensitive files, and run your project's checks at the end of a session. Those checks only run in projects you set up with the blueprint on your own machine, never in a folder you just downloaded.

## What is inside

```text
README.md, Install-guide.md      start here
course/                          one page per video episode, with examples
blueprint/MASTER-BLUEPRINT.md    how every part fits together
blueprint/global-claude.md       template for your personal ~/.claude/CLAUDE.md
blueprint/project-templates/     CLAUDE.md templates for coding, marketing and sales projects
blueprint/skills/                new-project, onboarding and more, plus packs for coding, design, marketing, sales
blueprint/agents/                researcher, implementer, reviewer
blueprint/hooks/                 the safety hooks and their test matrices
blueprint/scripts/               bootstrap.sh and blueprint-sync.sh (install and update)
```

## The video series

1. **Install**: install Claude Code and start it for the first time.
2. **Desktop setup**: VS Code, the extension and this blueprint.
3. **Server (optional)**: run Claude Code on a server of your own.
4. **Guardrails**: hooks and rules that catch dangerous commands and leaked secrets.
5. **Kick-off by voice**: describe a project out loud instead of typing it.
6. **Long sessions**: context, task files, and how the AI picks up the next day.

Videos and updates: [ailoopwise.com/en/starter](https://www.ailoopwise.com/en/starter)

## FAQ

**Is it free?** Yes. MIT licence, no account, no tracking. No telemetry: nothing reports back to us. Two things go online by design: the dependency check asks the npm registry about known vulnerabilities when you install packages, and the optional MCP servers in `blueprint/mcp/` connect to their own services if you switch them on.

**Do I need to code?** No. You paste one prompt and answer three questions. The course pages explain every step in plain words.

**Does it change my computer?** The quick start creates a new project folder and adds its path to `~/.claude/blueprint-projects`, the list of projects whose own checks may run. The optional global install (`blueprint/scripts/bootstrap.sh`, see [Install-guide.md](Install-guide.md)) adds the hooks to `~/.claude`, merges them into your existing settings without removing anything, and makes a dated backup first.

**How do I update?** Replace the `~/ailoopwise-blueprint` folder with the new release, then run `bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --dry-run` to see what would change, and the same command without `--dry-run` to apply it. Files you edited are never overwritten; the new version is saved next to them as `.blueprint-new`.

**How do I remove it?** Delete the project's `.claude/` folder and run `bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --unregister <project folder>`. For the global install, follow [Remove the global install](Install-guide.md#want-to-remove-the-global-install) in the install guide.

**Will the AI still make mistakes?** Yes. The rules and hooks make mistakes rarer and less costly; they do not make them impossible. Check what it does, and run the checks yourself.

## Contributing and security

Issues and ideas are welcome, see [CONTRIBUTING.md](CONTRIBUTING.md). To report a vulnerability, follow [SECURITY.md](SECURITY.md); please do not open a public issue for it.

## Licence

MIT, see [LICENSE](LICENSE). The templates are blank shapes; every example in them (companies, people, numbers) is fictional.

AILoopwise is not affiliated with, endorsed by or sponsored by Anthropic. Claude and Claude Code are trademarks of Anthropic, PBC.
