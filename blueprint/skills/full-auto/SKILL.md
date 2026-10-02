---
name: full-auto
description: "Checks that a project is ready for an unattended overnight loop (runs in Docker by default) and shows the command to start it."
when_to_use: "The user types /full-auto or asks for an overnight autonomous run. Not for short supervised runs (use /semi-auto) or for preparing the task queue (use /prepare-autonomous)."
disable-model-invocation: true
---

# /full-auto

Get the project ready for an overnight run, then hand the user the command to start it.

## Step 1: Check preparation

Look for `tasks/quality-protocol.md` and a Task Queue in `tasks/todo.md`.

- Both exist and `todo.md` has NOT_STARTED tasks: go to Step 2.
- Otherwise: run the `/prepare-autonomous` flow first.

## Step 2: Verify readiness

Every item has to pass, because nobody watches the run:

- [ ] `tasks/quality-protocol.md` exists
- [ ] `tasks/current.md` has Status, Domain and Exact Next Action
- [ ] `tasks/todo.md` has NOT_STARTED tasks
- [ ] The current branch is a feature branch (not main/master)
- [ ] The test command works
- [ ] The lint command works
- [ ] The secret-scanning pre-commit hook is installed in this repo: `.git/hooks/pre-commit` exists, or `git config core.hooksPath` (run in this repo) returns a path

Fix anything that fails now.

## Step 3: Check for Docker

Run `docker --version`.

**Docker available:**

```
Ready for full-auto (Docker).

Exit Claude Code, then run:

  docker run --rm -v "$(pwd)":/project -w /project \
    -v ~/ailoopwise-blueprint/blueprint/scripts:/blueprint-scripts:ro \
    claude-auto bash /blueprint-scripts/full-auto-loop.sh . 30

(`claude-auto` stands for a Docker image you built with Claude Code, git, jq and your
project's tools inside. The blueprint does not ship one.)

Morning review:
  cat tasks/logs/overnight-$(date '+%Y-%m-%d')-summary.md
  cat tasks/blockers.md
  git log --oneline --not main
```

**Docker not available:**

```
Docker not found.

Full-auto runs 30+ unattended iterations. Docker keeps anything unexpected inside a container.

Options:
  1. Install Docker Desktop: https://www.docker.com/products/docker-desktop/
  2. Use /semi-auto instead (no Docker, you stay nearby)
  3. Run without Docker at your own risk (one-time setting):
       echo "I_ACCEPT_BARE_METAL_RISK=true" > ~/.claude-auto-config
     then: bash ~/ailoopwise-blueprint/blueprint/scripts/full-auto-loop.sh . 30
     (on macOS, put `caffeinate -s` in front so the Mac does not sleep)
```

The loop starts its own Claude Code sessions, so it runs from the user's terminal, not from inside this session.
