---
name: new-project
description: "Sets up a project folder with the blueprint: project CLAUDE.md, task files, a domain skill pack, agents and safety hooks."
when_to_use: "Starting a new project, or the user says 'new project', 'set up project', 'init project', 'start a new [domain] project', or opens a folder that has no .claude/ setup. Not for creating new skill packs (use /new-domain)."
---

# New Project Setup

Set up a project so Claude knows what it is working on, which rules apply, and where work stopped last time.

Use Read, Write and Glob for text files. Use Bash for copying folders and for the install script.
Do not overwrite a file that already exists in the project: keep it, and tell the user what you would have changed.

## Step 1: Gather project info

Ask, one at a time:
1. **Project name**
2. **Domain**: `coding`, `marketing`, `sales`, `design`, `multi` (several packs), or `other` (no pack yet; suggest /new-domain afterwards)
3. **One-sentence description**
4. **Details for the domain**: tech stack (coding), audience and channels (marketing), ideal customer and sales process (sales), platform and design system (design)

Continue once you have at least name, domain and description.

## Step 2: Locate the blueprint

Check with Glob, in this order:
1. `~/ailoopwise-blueprint/blueprint/MASTER-BLUEPRINT.md`
2. `~/blueprint/MASTER-BLUEPRINT.md`

If neither exists, ask the user where the `blueprint/` folder is. Below, `BLUEPRINT` means that folder.

## Step 3: Choose the project folder

Create the project in a new folder next to the blueprint, named after the project (for example `~/<project-name>/`). Never inside the blueprint folder. If the current folder is already the user's own project (not the blueprint), use it.

Below, `PROJECT` means the absolute path of that folder (the full path starting with `/`, as `pwd` prints it inside that folder). Use it in every path and command: this session may still be running in the blueprint folder, so a relative path like `.` or `.claude/` would write into the blueprint.

The result looks like this:

```
.claude/
├── CLAUDE.md          from a project template + the user's answers
├── skills/            the domain skill pack(s)
├── agents/            researcher, implementer, reviewer
├── hooks/             safety and quality hooks (copies; skipped when installed globally)
├── settings.json      registers the hooks
└── .blueprint         marker: blueprint-sync.sh only updates projects that have it
.mcp.json              optional MCP servers
tasks/
├── current.md         where work stands
├── lessons.md         rules learned from mistakes
└── todo.md            what is next
```

## Step 4: Task files

Copy `BLUEPRINT/tasks/current.md`, `lessons.md` and `todo.md` into `PROJECT/tasks/`. Skip any that already exist.

## Step 5: Project CLAUDE.md

Pick the template from `BLUEPRINT/project-templates/`:
- coding → `coding-project-claude.md`
- marketing → `marketing-project-claude.md`
- sales → `sales-project-claude.md`
- design or other → `coding-project-claude.md`, adapted (drop what does not apply)
- multi → combine the relevant templates, keep one "Rules" section

Replace every `[placeholder]` with the user's answers and write the result to `PROJECT/.claude/CLAUDE.md`. If the user named things the AI must not do, put them in the Rules section as plain, specific sentences. Keep the file under 60 lines; procedures belong in skills.

## Step 6: Skills and agents

Copy each skill folder of the chosen pack(s) into `PROJECT/.claude/skills/` (for example `cp -R "BLUEPRINT/skills/coding/debug" "PROJECT/.claude/skills/"`). Skip folders that already exist.
- coding → `BLUEPRINT/skills/coding/*/`
- marketing → `BLUEPRINT/skills/marketing/*/`
- sales → `BLUEPRINT/skills/sales/*/`
- design → `BLUEPRINT/skills/design/*/`
- other → no pack; suggest /new-domain

Also copy, whatever the domain: `new-domain`, `autoresearch`, `onboarding` (from `BLUEPRINT/skills/`), and the three agents from `BLUEPRINT/agents/` into `PROJECT/.claude/agents/`.

## Step 7: Hooks and install record

Decide whether this project needs its own hook copies. If `~/.claude/settings.json` exists and contains `.claude/hooks/block-dangerous-commands.sh`, the global hooks already cover this project: do not create `PROJECT/.claude/hooks/`. Otherwise create it.

Then always run (with the real paths filled in, quoted):

```bash
mkdir -p "PROJECT/.claude" && touch "PROJECT/.claude/.blueprint"
bash "BLUEPRINT/scripts/blueprint-sync.sh" --project "PROJECT"
```

The script records which agent and skill files came from the blueprint, so later updates can tell your changes from the blueprint's. It also adds `PROJECT` to `~/.claude/blueprint-projects`, the user's own list of projects whose quality checks may run the project's tools (lint, tests); a repo cannot add itself to that list. If `PROJECT/.claude/hooks/` exists, it also copies the hook scripts there and merges the hooks into `PROJECT/.claude/settings.json`, keeping anything already in it. Check its output for `ERROR` and report any to the user.

## Step 8: MCP (optional)

If the user wants MCP servers, copy `BLUEPRINT/mcp/.mcp.json` to `PROJECT/.mcp.json` and keep only the servers they need. The file reads tokens from environment variables (`GITHUB_TOKEN`, `BRAVE_API_KEY`); tell the user to set those, and not to paste tokens into the file. Keep the GitHub server read-only and the package versions pinned, and do not keep `playwright` (a browser) together with a server that can write to the repo: text on a web page could then make changes there.

## Step 9: First entry in current.md

Fill in `PROJECT/tasks/current.md`: Active Task "Project setup", the domain and packs installed under Decisions Made, and suggested first actions under Next Steps.

## Step 10: Verify

Check with Glob and Read, all under `PROJECT/`:
1. `.claude/CLAUDE.md` exists and has no `[placeholder]` left
2. `.claude/skills/` has the chosen pack(s)
3. `tasks/` has current.md, lessons.md, todo.md
4. `.claude/.blueprint` and `.claude/.blueprint-manifest` exist, and `PROJECT` is a line in `~/.claude/blueprint-projects`
5. Hooks: either the global hooks are active, or `.claude/hooks/` has the scripts and `.claude/settings.json` lists them

Report the result, listing every file you created.

## Step 11: .gitignore

If `PROJECT/.gitignore` exists, add these lines (they hold local state and tokens):
```
.claude/settings.local.json
.mcp.json
tasks/current.md
```
Suggest committing everything else. To back up the working state too, the user can remove the `tasks/current.md` line.

## Step 12: Onboard the user

Run `/onboarding` to show what was installed and how to use it.
