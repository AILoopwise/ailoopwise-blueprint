# Claude Code Master Blueprint

This guide explains what is in the `blueprint/` folder and how to use it. Every path below exists in this folder.

There are two ways in:

- **One project** (most people start here): open the blueprint folder in Claude Code and run `/new-project`, as the README describes. Everything goes into the new project's own `.claude/` folder.
- **Every project on this computer**: run `bootstrap.sh` once (Phase 1). It installs the global CLAUDE.md, hooks, agents and core skills into `~/.claude/`.

---

## What is in this folder

```
blueprint/
├── MASTER-BLUEPRINT.md          this guide
├── global-claude.md             template for ~/.claude/CLAUDE.md
├── skill-writing-guide.md       how to write your own skills
├── agents/                      researcher, implementer, reviewer
├── hooks/
│   ├── settings.json            registers the hooks below
│   ├── session-start.sh         jq check + points to tasks/ at session start
│   ├── block-dangerous-commands.sh
│   ├── block-dangerous-commands.matrix.sh   tests for the hook above
│   ├── defer-to-project.matrix.sh           tests: which global hooks step aside for a project copy
│   ├── protect-sensitive-files.sh
│   ├── detect-secrets-in-code.sh
│   ├── format-and-lint.sh
│   ├── owasp-check.sh
│   ├── audit-dependencies.sh
│   └── quality-check.sh
├── mcp/.mcp.json                example MCP servers (tokens from environment variables)
├── project-templates/           coding, marketing, sales CLAUDE.md starters
├── scripts/
│   ├── bootstrap.sh             global install (Phase 1)
│   ├── blueprint-sync.sh        update earlier installs after the blueprint changes
│   ├── lib-install.sh           shared by the two scripts above
│   ├── merge-hooks.jq           merges hooks into a settings.json
│   ├── semi-auto-loop.sh        supervised loop (Phase 4)
│   ├── full-auto-loop.sh        overnight loop (Phase 4)
│   └── pre-commit-security.sh   git hook that blocks committed secrets
├── tasks/                       current.md, lessons.md, todo.md templates
└── skills/
    ├── coding/        code-review, debug, deploy, pr-gen, refactor, security-audit, test-gen
    ├── marketing/     blog-post, content-gen, email-sequence, humanize, seo-audit, social-content
    ├── sales/         competitor-analysis, follow-up, objection-handling, outreach, proposal
    ├── design/        a11y-check, component-spec, design-system, hig-review, responsive-audit, ui-review, ux-flow
    ├── new-project/   new-domain/   onboarding/   autoresearch/   claude-api/
    ├── prepare-autonomous/   semi-auto/   full-auto/
    └── template/example-skill/   starting point for your own skill
```

Each skill is a folder with a `SKILL.md`; some have a `reference/` or `references/` folder that the skill reads when it needs it.

---

# Phase 1: Global install (optional)

Prerequisites: Claude Code and **jq** (the hooks read their input with it; without jq, edits and writes are blocked until it is installed, while the command guard keeps working with its built-in reader). Install jq from https://jqlang.org/download/ (macOS: `brew install jq`, Linux/WSL: `sudo apt-get install -y jq`).

```bash
bash ~/ailoopwise-blueprint/blueprint/scripts/bootstrap.sh
```

What it does, and what it leaves alone:

| Installs into `~/.claude/` | Behaviour on an existing file |
|---|---|
| `CLAUDE.md` from `global-claude.md` | If yours differs, it stays; the new version is saved beside it as `CLAUDE.md.blueprint-new` |
| `hooks/*.sh` | Same rule: files you changed are never overwritten |
| `agents/` (3 agents) | Same rule |
| `skills/`: new-project, new-domain, onboarding, autoresearch, claude-api, security-audit, prepare-autonomous, semi-auto, full-auto | Same rule, file by file |
| hooks in `settings.json` | Merged: your settings and your own hooks stay, the blueprint's hooks are added once. A timestamped backup is made before any change |

Running it again is safe. Afterwards: restart Claude Code, then fill in the `[placeholders]` in `~/.claude/CLAUDE.md`.

Keep `~/.claude/CLAUDE.md` short: it is loaded in every session of every project. Procedures belong in skills, and rules that must always run belong in hooks.

## The hooks

Hooks run outside the model, at no context cost. The ones that exit with code 2 stop the action and tell Claude why.

| Script | Event | Effect |
|---|---|---|
| `session-start.sh` | SessionStart | Warns if jq is missing; points Claude to `tasks/current.md` and `tasks/lessons.md` |
| `block-dangerous-commands.sh` | PreToolUse (Bash) | Blocks `rm -rf` of root, home, the project or its parent, hard resets, `git clean -fd`, force-push, `git checkout`/`git restore` of files, destructive SQL, commands that print secrets, `npm publish` |
| `protect-sensitive-files.sh` | PreToolUse (Edit/Write) | Blocks writes to `.env`, lockfiles, `.git/`, `.ssh/`, keys |
| `detect-secrets-in-code.sh` | PreToolUse (Edit/Write) | Blocks a write that contains an API key, private key or password-bearing URL |
| `format-and-lint.sh` | PostToolUse (Edit/Write) | Runs the project's own `eslint --fix` on JS/TS files (never downloads eslint) |
| `owasp-check.sh` | PostToolUse (Edit/Write) | Warns about SQL injection, `innerHTML`, `eval`, `shell=True` and similar |
| `audit-dependencies.sh` | PostToolUse (Bash) | Runs the package manager's audit after an install |
| `quality-check.sh` | Stop | Typecheck, lint, format check and (when code changed) tests; blocks the stop once if types or tests fail |

Test the command guard after changing it: `bash blueprint/hooks/block-dangerous-commands.matrix.sh blueprint/hooks/block-dangerous-commands.sh`.

/new-project skips project hook copies when the global hooks are active. If a project does have its own copies, the global copy of the same hook steps aside in that project, so no check runs twice. The three security hooks (`block-dangerous-commands.sh`, `protect-sensitive-files.sh`, `detect-secrets-in-code.sh`) are the exception: their global copy always runs, so no file in a project can switch them off.

**Which projects run their own tools.** `quality-check.sh` and `format-and-lint.sh` run the project's own commands (`npm run lint`, tests, its eslint and eslint config), and those can be any code the folder ships. So they only act in projects you opted in: folders listed, one per line, in `~/.claude/blueprint-projects`. That list is yours, on this computer; nothing inside a repo can put a folder on it, so a repo you downloaded to look at never runs its own scripts through these hooks. `/new-project` adds the new project. To opt in a project you set up earlier, run `bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --project <folder>`; to take one off again, the same script with `--unregister <folder>`. Opt in only folders whose code you trust.

## MCP servers

MCP connects Claude Code to outside services. For one project, copy `blueprint/mcp/.mcp.json` to the project root and keep only what you need. It reads tokens from environment variables (`GITHUB_TOKEN`, `BRAVE_API_KEY`), so no token is written into the file. The GitHub server is read-only (`X-MCP-Readonly`) and every `npx` package is pinned to an exact version, so nothing updates itself. Do not combine a browser server (playwright) with a server that can write to your code or repositories: text on a web page can carry instructions that Claude then carries out with that write access. For all projects, add a server with `claude mcp add --scope user <name> ...`. Type `/mcp` inside Claude Code to see which servers are connected.

## Settings

Change Claude Code settings with `/config`, or edit `~/.claude/settings.json` (all projects) or `.claude/settings.json` (one project).

---

# Phase 2: Set up a project

Open the project folder (or the blueprint folder, for a brand-new project) in Claude Code and type:

```
/new-project
```

It asks four questions, then creates:

```
.claude/CLAUDE.md       from a template in project-templates/, with your answers
.claude/skills/         the skill pack for your domain + new-domain, autoresearch, onboarding
.claude/agents/         researcher, implementer, reviewer
.claude/hooks/          copies of the hooks (skipped if installed globally)
.claude/settings.json   hooks registered (merged if the file already exists)
.claude/.blueprint      marker for blueprint-sync.sh
.claude/.blueprint-manifest   which files came from the blueprint (so updates never overwrite your edits)
tasks/current.md        where work stands
tasks/lessons.md        rules learned from mistakes
tasks/todo.md           what is next
```

If `/new-project` is not available, ask Claude to read `blueprint/skills/new-project/SKILL.md` and follow it.

## The project CLAUDE.md

Keep it under about 60 lines: what the project is, the commands to build and test it, the folder layout, conventions, and the rules the AI must not break. Claude reads it every session.

Rules that only matter for part of the code go into `.claude/rules/<topic>.md`, with a `paths:` list at the top so they load only when Claude works on matching files:

```markdown
---
paths:
  - "src/api/**"
---
All API handlers validate input with the shared schema in src/api/schema.ts.
```

## Keeping installs up to date

When this blueprint folder gets a newer version, run:

```bash
bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --dry-run   # preview
bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh             # apply
```

It updates the global install (if bootstrap made it) and every project with a `.claude/.blueprint` marker: hook scripts, agents, and the blueprint skills a project already has, plus the hooks in each `settings.json` (merged). A file you changed is never overwritten; the new version appears beside it as `<name>.blueprint-new`, and you merge it when you want. It does not touch project `CLAUDE.md`, `.mcp.json` or `tasks/`.

- **Where it looks:** projects up to 3 folder levels below your home folder (`~/a/b/c`). For deeper projects add `--depth 5`, or update one project with `--project <folder>`.
- **Deleted files come back.** A blueprint file you delete (an agent, a skill file) is installed again on the next sync. To keep it gone, list it in `.claude/.blueprint-ignore` of that project (or `~/.claude/.blueprint-ignore`), one path per line, for example `agents/reviewer.md` or `skills/debug`.
- **To switch off a hook**, don't delete it (the settings entry would remain): change the script to just `exit 0`. Sync then keeps your version.

Hooks are copied, not linked, so moving the blueprint folder does not switch them off.

---

# Phase 3: Daily work

**Start:** `Read tasks/current.md and tasks/lessons.md. Summarize where we left off.`

**Skills** load on their own when a task matches, or call one directly: `/code-review src/api/auth.ts`. Skills that change things (deploy, autonomous mode) only run when you type them.

**Subagents** work in their own context window and return a summary:

```
@researcher Find the top 3 rate limiting libraries for Node.js
@implementer Find and fix why /api/users returns 500 on POST
@reviewer Review the changes on this branch
```

**Plan mode** (Shift+Tab): Claude reads and plans but changes nothing.

**Context:** `/context` shows how full the context window is (the size depends on the model). Quality drops as it fills: at around two thirds, run `/compact`; if the session goes off track, update `tasks/current.md`, run `/clear`, then `Read tasks/current.md and continue.` `/rewind` undoes recent steps.

**End:** `Update tasks/current.md with what we did and the exact next step. Add any lesson to tasks/lessons.md.`

---

# Phase 4: Autonomous runs

Claude works through a task queue without you. Do Phases 1-3 first, and always start with `/prepare-autonomous` interactively.

## Step 4.1: Secret scanning on commit

Install the pre-commit hook in the project's git repository:

```bash
cp ~/ailoopwise-blueprint/blueprint/scripts/pre-commit-security.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

This is per repository on purpose. Setting `core.hooksPath` globally would switch off every other repository's own git hooks.

## Step 4.2: `/prepare-autonomous`

Turns your PRD into `tasks/quality-protocol.md` (checks per commit, per task, and a human review per PRD), a numbered queue in `tasks/todo.md`, the first task in `tasks/current.md`, and a feature branch. Questions the loop cannot answer later land in `tasks/blockers.md`.

## Step 4.3: Choose a mode

- **Interactive** (default): work through the queue together.
- **`/semi-auto`**: a loop of about 1-2 hours while you are nearby; stop with Ctrl+C.
- **`/full-auto`**: an overnight loop, in Docker by default.

Both skills check readiness and print the exact command to run in a terminal. The loops use `claude -p` with a restricted tool list and refuse to run on main/master.

## Step 4.4: Morning review

```bash
git log --oneline main..HEAD          # what was built
git diff main...HEAD                  # full diff
cat tasks/blockers.md                 # questions for you
cat tasks/logs/overnight-*-summary.md # full-auto only
```

Then ask Claude for an audit of the branch (architecture, security, test coverage, code quality, with file:line references) before you merge.

---

# Appendix A: Troubleshooting

| Command | Purpose |
|---|---|
| `/doctor` | Health check of the installation |
| `/status` | Model, account, settings sources |
| `/hooks` | Which hooks are active and where they come from |
| `/mcp` | MCP server status |
| `/context` | Context usage |
| `claude --debug` | Debug log, including hook and MCP errors |
| `claude -p "..."` | Run one prompt without the interactive UI |

**Edits are blocked with "safety hooks need jq":** check `jq --version` and install jq. Without it the edit and write hooks block instead of running unchecked; the session-start hook warns about this.

**A skill does not trigger:** check its `description` and `when_to_use`, and that the folder is in `~/.claude/skills/` or `.claude/skills/`. Skills with `disable-model-invocation: true` only run when you type `/name`.

**MCP server fails:** `/mcp` shows the error. Check that the command (`npx`, `uvx`) is installed and the environment variables are set.

---

# Appendix B: What costs context

| Extension | Context cost | Use for |
|---|---|---|
| CLAUDE.md | Loaded every session | Short, always-true project facts and rules |
| `.claude/rules/*.md` with `paths:` | Loaded when matching files are touched | Rules for one area of the code |
| Skills | Name and description always; body only when used | Procedures and domain workflows |
| Subagents | Own context window; only the result comes back | Research, exploration, reviews |
| Hooks | None | Checks that must always run |
| MCP | Tool definitions | Outside services |

---

# Appendix C: Where things live

| What | All projects | One project |
|---|---|---|
| Instructions | `~/.claude/CLAUDE.md` | `./CLAUDE.md` or `./.claude/CLAUDE.md` |
| Area rules | `~/.claude/rules/` | `.claude/rules/` |
| Skills | `~/.claude/skills/` | `.claude/skills/` |
| Agents | `~/.claude/agents/` | `.claude/agents/` |
| Hooks and settings | `~/.claude/settings.json` | `.claude/settings.json` |
| MCP | `claude mcp add --scope user` | `./.mcp.json` |
| Working state | — | `tasks/current.md`, `tasks/lessons.md`, `tasks/todo.md` |
