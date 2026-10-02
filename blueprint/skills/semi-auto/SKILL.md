---
name: semi-auto
description: "Checks that a project is ready for a semi-autonomous loop (1-2 hours, user nearby) and shows the command to start it from a terminal."
when_to_use: "The user types /semi-auto or asks to start a short supervised loop over the task queue. Not for overnight runs (use /full-auto) or for preparing the task queue (use /prepare-autonomous)."
disable-model-invocation: true
---

# /semi-auto

Get the project ready for a short supervised loop, then hand the user the command to run in a terminal.

## Step 1: Check preparation

Look for `tasks/quality-protocol.md` and a Task Queue in `tasks/todo.md`.

- Both exist and `todo.md` has NOT_STARTED tasks: go to Step 2.
- Otherwise: run the `/prepare-autonomous` flow first (domain, PRD, quality protocol, task queue, feature branch).

## Step 2: Verify readiness

- [ ] `tasks/quality-protocol.md` exists
- [ ] `tasks/current.md` has Status, Domain and Exact Next Action
- [ ] `tasks/todo.md` has NOT_STARTED tasks in the Task Queue
- [ ] The current branch is a feature branch (not main/master)
- [ ] The test command works
- [ ] The lint command works

Fix anything that fails together with the user.

## Step 3: Show the launch command

```
Ready for semi-auto.

Exit Claude Code, then paste this into a terminal:

  bash ~/ailoopwise-blueprint/blueprint/scripts/semi-auto-loop.sh . 10

10 iterations (about 1-2 hours). Each one: fresh session, build, test, lint, commit.
Stop any time with Ctrl+C. Use 5 or 20 instead of 10 for a shorter or longer run.
Blockers the loop could not solve land in tasks/blockers.md.
```

The loop starts its own Claude Code sessions, so it runs from the user's terminal, not from inside this session.
