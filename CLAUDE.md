# AILoopwise Blueprint

This folder is a blueprint: templates, skills, agents and safety hooks for Claude Code. The person using it is usually not a developer, so explain things in plain words and one step at a time.

## Leave this folder as it is
Do not edit, move or delete files here. It is the source that projects are copied from, and the update script (`blueprint/scripts/blueprint-sync.sh`) compares against it. Create new projects in their own folder next to this one.

## Starting a new project
1. Ask what the project is, what the user sells and to whom, and what the AI must never do in it.
2. Run `/new-project`. If it is not available, read `blueprint/skills/new-project/SKILL.md` and follow its steps.
3. The new folder gets `.claude/CLAUDE.md`, `tasks/current.md`, `tasks/lessons.md` and `tasks/todo.md`.
4. Show the user which files you created and how to open the new folder in VS Code.

## Where to look
- `README.md` (English) and `README.de.md` (German) — the user's own instructions
- `blueprint/MASTER-BLUEPRINT.md` — what each part of the blueprint does
- `course/` — the step-by-step pages for the video series
- `Install-guide.md` — optional install for every project on the computer (`blueprint/scripts/bootstrap.sh`)

## Prerequisite
The safety hooks need `jq`. If `jq --version` fails, help the user install it first (https://jqlang.org/download/).
