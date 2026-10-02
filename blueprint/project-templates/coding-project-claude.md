# [Project Name]
[One sentence: what this project is and does]

## Stack
- [Language / framework]
- [Database]
- [Hosting]

## Commands
- Install: [command]
- Dev server: [command]
- Test: [command]
- Lint: [command]
- Typecheck: [command]
- Format check: [command]
- Build: [command]

## Layout
- `[folder]/` — [what lives there]
- `[folder]/` — [what lives there]

## Conventions
- [Naming]
- [Where tests live]
- [Anything a newcomer would get wrong]

## Rules
- [What the AI must not do in this project, as specific sentences]

## Mandatory Quality Checks
Before calling a task done, run typecheck, lint, tests, format check and build (the commands above) and report each result.
New features get a happy-path test and one edge case; bug fixes get a regression test.

## Working state
- `tasks/current.md` where work stands · `tasks/lessons.md` rules learned here · `tasks/todo.md` what is next
- Rules for one part of the code go in `.claude/rules/<topic>.md` with a `paths:` list, so they load only when that code is touched.
