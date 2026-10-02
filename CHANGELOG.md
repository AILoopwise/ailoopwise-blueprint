# Changelog

Versions are dated: `vYYYY.MM.DD`, the day the release is tagged. Each release on GitHub carries the ZIP and its SHA256 checksum.

## First public release

- Quick start for non-developers: one prompt, three questions, a new project folder with `CLAUDE.md` and three task files.
- Six course pages that go with the video series, with examples (PRD template, continuation prompt, server checklist).
- Command guard rewritten: blocks the commands that lose work (deleting home, `.git`, the current folder; hard resets; force pushes; database and volume resets; reading `.env` files), allows normal work (build folders, `--force-with-lease`, unstaging, `docker compose down`), and blocks when the check itself fails. 716-case test matrix.
- Project checks (lint, typecheck, tests at the end of a session) only run in projects registered on your own machine, never in a downloaded folder.
- Security hooks always run; other global hooks step aside when a project ships its own copy, so nothing runs twice.
- Install and sync merge settings instead of replacing them, keep files you edited (new version saved as `.blueprint-new`), refuse to write through symlinks in projects, and keep dated backups.
- Commands became skills; `/full-auto` and `/semi-auto` start only when you call them.
- Test workflow on Linux, macOS and Windows; releases build a ZIP with the right folder name.
