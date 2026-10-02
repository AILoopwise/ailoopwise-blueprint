---
name: onboarding
description: "Explain the Claude Code blueprint system to new users. Covers installed skills, agents, hooks, task system, autonomous mode, and customization. Trigger on: 'how does this work', 'explain the system', 'onboard me', 'what skills available', 'show me around', 'help me get started', 'what can you do', 'list capabilities'. Do not use for: project initialization (use new-project), creating new skill packs (use new-domain)."
---

# Onboarding Guide

You are orienting a user to the Claude Code blueprint system installed in this project (or globally). Scan the environment and present a clear, actionable overview.

Use Glob and Read to scan; Bash is not needed here.

## Step 1: SCAN ENVIRONMENT
Detect what is installed by checking these locations using Glob:

**Global skills:** `~/.claude/skills/*/SKILL.md`
**Project skills:** `.claude/skills/*/SKILL.md`
**Global agents:** `~/.claude/agents/*.md`
**Project agents:** `.claude/agents/*.md`
**Hooks:** `.claude/settings.json` and `~/.claude/settings.json` (read the `hooks` key)
**Task system:** `tasks/current.md`, `tasks/lessons.md`, `tasks/todo.md` (plus `tasks/blockers.md` once autonomous mode has run)
**MCP servers:** `.mcp.json`
**Project config:** `.claude/CLAUDE.md`

## Step 2: PRESENT INVENTORY
Show a structured overview of everything **actually found** in Step 1:

### Skills (slash commands)
| Skill | Domain | What it does |
|-------|--------|-------------|

Read each SKILL.md's `description` field and populate this table. Only list skills that exist.

### Agents (subagents)
| Agent | Role |
|-------|------|

Read each agent `.md` file's first line/description. Only list agents that exist.

### Hooks (automated checks)
List each hook event (SessionStart, PreToolUse, PostToolUse, Stop) and what scripts run.
Only list hooks actually found, and say whether they come from the project or the global settings.

### Task System
List only the task files that actually exist in `tasks/`. Explain each one:
- `tasks/current.md` — where work stands; read at session start, updated at the end
- `tasks/lessons.md` — rules learned from mistakes
- `tasks/todo.md` — what is next
- `tasks/blockers.md` — only after an autonomous run: questions the loop could not answer

### MCP Servers
List configured MCP servers from `.mcp.json` if present.

## Step 3: QUICK REFERENCE CARD
Generate a compact reference card from what was found in Step 1. Build it from the scan results only, not from a fixed list.

Format:
```
SKILLS (type these as commands):
  /skill-name — description (from SKILL.md)
  ...

AGENTS (used automatically by skills):
  @agent-name — role (from agent .md)
  ...

TASK SYSTEM:
  tasks/current.md  — Read at session start, update at end
  tasks/lessons.md  — Append when you learn something unexpected
  ...

AUTONOMOUS MODE (if installed):
  /prepare-autonomous — Convert a PRD into a task queue
  /semi-auto          — Short supervised loop over the queue
  /full-auto          — Overnight loop (Docker)
```

## Step 4: EXPLAIN KEY WORKFLOWS
Based on the **installed skills** (not hardcoded lists), suggest relevant workflows.

Group by domain if multiple packs are installed. For each installed skill, briefly explain when to use it. Example format:

**Coding workflows** (only if coding skills installed):
- Write code → hooks auto-check for security, formatting, quality
- `/code-review` before PRs, `/test-gen` for coverage gaps

**Marketing workflows** (only if marketing skills installed):
- `/content-gen` for drafts, `/humanize` to remove AI patterns

Only show workflow sections for domains that have skills installed.

## Step 5: OFFER NEXT STEPS
Based on the current project state, suggest what to do next:
- If no project setup: "Run `/new-project` to initialize this project"
- If project is set up but no tasks: "What would you like to work on first?"
- If tasks exist: "You have active work in `tasks/current.md` — want to continue?"
- If skills are missing for their domain: "Want me to create custom skills with `/new-domain`?"

## OUTPUT
Keep the output scannable — use tables and the reference card. Don't overwhelm with text.
The goal is: user finishes reading and knows exactly what commands to use and how the system works.
