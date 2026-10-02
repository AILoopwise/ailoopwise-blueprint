# BLUEPRINT INSTALLATION & USAGE GUIDE

---

## PART 1: GLOBAL INSTALL (optional, once per computer)

This makes the blueprint's CLAUDE.md, hooks, agents and core skills available in every project.
For a single project you can skip this part and use `/new-project` (see the README).

### Prerequisites
- Claude Code: follow Anthropic's install guide, https://code.claude.com/docs/en/setup (the method changes over time, so use that page rather than a copied command)
- This folder at `~/ailoopwise-blueprint`
- **jq**, which the safety hooks need to read their input (without it, edits and writes are blocked until it is installed; the command guard still works):
  - macOS: `brew install jq`
  - Linux / Windows with WSL: `sudo apt-get install -y jq`
  - Windows without WSL: `winget install jqlang.jq`
  - Anything else: https://jqlang.org/download/
  - Check: `jq --version`
- **Windows only:** WSL 2, or Git for Windows (https://git-scm.com/download/win) so Claude Code has Bash — the hooks are Bash scripts and do not run without it

### Step 1: Run the installer
```bash
bash ~/ailoopwise-blueprint/blueprint/scripts/bootstrap.sh
```
It installs into `~/.claude/` and is safe to run again:
- a file you changed is never overwritten; the new version is saved beside it as `<name>.blueprint-new`
- `~/.claude/settings.json` is merged, not replaced: your settings and your own hooks stay, the blueprint's hooks are added once, and a timestamped backup is made before any change

### Step 2: Restart Claude Code and check
Restart Claude Code, then type `/hooks` (the blueprint hooks are listed) and ask "What skills are available?" (you should see new-project, new-domain, onboarding and the others).

### Step 3: Fill in your identity
Open `~/.claude/CLAUDE.md` in your editor (in VS Code: File → Open File…) and replace `[Your Name]`, `[Your Role]`, `[Company]` and the other placeholders.

### Optional: agent teams (experimental)
Agent teams are switched on with the environment variable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Add it to your shell's startup file (for example `~/.bashrc` or `~/.zshrc`), or to the `env` section of `~/.claude/settings.json`.

**Global install complete.** It applies every time you start Claude Code.

---

## PART 2: NEW PROJECT SETUP

### The flow for every new project:

```bash
# 1. Create or clone your project
mkdir my-new-project        # OR: git clone [repo-url]
cd my-new-project

# 2. Open Claude Code
claude

# 3. Run the setup command
/new-project
```

Claude will ask you 3-4 questions, then automatically set up everything.

### If /new-project doesn't trigger, paste this prompt:

```
Set up this project using the blueprint. Here's the info:

Project name: [YOUR PROJECT NAME]
Domain: [coding / marketing / sales / multi / other]
Description: [ONE SENTENCE ABOUT THE PROJECT]
Tech stack / audience: [RELEVANT DETAILS]

My blueprint folder is at: ~/ailoopwise-blueprint/blueprint/

Please:
1. Create .claude/ folder with the right CLAUDE.md template from blueprint/project-templates/
2. Copy the [domain] skill pack from blueprint/skills/[domain]/ to .claude/skills/
3. Create tasks/ with current.md, lessons.md and todo.md from blueprint/tasks/
4. If ~/.claude/settings.json does not already list .claude/hooks/block-dangerous-commands.sh (no global install), create the folder .claude/hooks/ in this project. Then create the file .claude/.blueprint and run:
   bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --project "<the absolute path of this project>"
   (copies the safety hooks into .claude/hooks/ when that folder exists, records which files came from the blueprint, and registers the project so its own checks may run)
5. Only if I ask for MCP servers: copy blueprint/mcp/.mcp.json to the project root and explain each server first
6. Fill in all [bracket] placeholders with my project info
7. Show me what was created and what commands are available
```

### Example prompts for different project types:

**Coding project:**
```
/new-project
→ Domain: coding
→ Name: SaaS Backend API
→ Description: REST API for our analytics platform
→ Tech: Node.js, TypeScript, PostgreSQL, Docker
```

**Marketing project:**
```
/new-project
→ Domain: marketing
→ Name: Product Launch Campaign
→ Description: Content strategy for new analytics tool launch
→ Audience: VP Marketing at mid-market SaaS companies
```

**Sales project:**
```
/new-project
→ Domain: sales
→ Name: Enterprise Outreach
→ Description: Outbound sales campaign targeting Fortune 500
→ ICP: CTO/VP Engineering, 1000+ employees, using legacy analytics
```

**Multi-domain project:**
```
/new-project
→ Domain: multi
→ Name: Product Website
→ Description: Full website with landing pages and sales funnel
→ Details: Need both coding (Next.js) and marketing (content, SEO)
```

**New domain (not covered):**
```
/new-project
→ Domain: other
→ Name: Investment Analysis
→ Description: Due diligence and financial modeling for deals

(After setup, Claude will suggest running /new-domain to create a finance skill pack)
```

---

## PART 3: DAILY USAGE

### Starting a work session
```bash
cd my-project
claude
```
Claude automatically:
- Loads global + project CLAUDE.md
- Checks tasks/current.md for where you left off
- Checks tasks/lessons.md for rules to follow
- Has all your skills and agents ready

### Key commands
| Command | What it does |
|---------|-------------|
| `/new-project` | Set up a new project with blueprint |
| `/new-domain` | Create a skill pack for a new domain |
| `/compact` | Compress context when session gets long |
| `/clear` | Reset context for a fresh start |
| `/status` | Check session info and context usage |
| `/context` | Visual context usage breakdown |

### Domain skill commands (after installing a pack)

**Coding pack:**
| Command | What it does |
|---------|-------------|
| `/code-review` | 4-layer review (Architecture → Quality → Tests → Performance) |
| `/debug` | Root-vs-symptom diagnosis |
| `/refactor` | Elegance-seeking refactoring |
| `/test-gen` | Edge-case focused test generation |
| `/pr-gen` | PR description from git diff |
| `/security-audit` | Security scanning checklist |
| `/deploy` | Deployment workflow |

**Marketing pack:**
| Command | What it does |
|---------|-------------|
| `/content-gen` | Recursive quality loop content generation |
| `/seo-audit` | Competitor analysis and content strategy |
| `/humanize` | Two-pass AI-to-human content transformation |
| `/email-sequence` | Drip sequence with A/B variants |
| `/social-content` | Platform-specific social media content |
| `/blog-post` | SEO-optimized long-form articles |

**Sales pack:**
| Command | What it does |
|---------|-------------|
| `/outreach` | Multi-touch cold outreach sequences |
| `/proposal` | Proposal writing with competitive positioning |
| `/competitor-analysis` | Battle card generation |
| `/objection-handling` | Objection→response library |
| `/follow-up` | Follow-up sequence optimization |

### Ending a session
- Update tasks/current.md with what you did and the exact next step
- Add to tasks/lessons.md if you learned something

---

## PART 4: TROUBLESHOOTING

### Claude doesn't see global skills
```bash
ls ~/.claude/skills/
```
Should show `new-project/`, `new-domain/` and the other core skills. If not, run the installer from Part 1 again.

### /new-project can't find blueprint folder
Tell Claude where it is:
```
My blueprint folder is at ~/ailoopwise-blueprint/blueprint/
```

### Skills not triggering automatically
Skills with `disable-model-invocation: true` only trigger when you type the command. Use the `/` prefix.

### Context getting heavy
```
/compact
```
Or for a fresh start:
```
/clear
```

### Want to remove the global install
Your own files live in the same folders, so remove only what the blueprint installed:
- `~/.claude/.blueprint-manifest` lists every file the installer put in `~/.claude/`; delete those files.
- In `~/.claude/settings.json`, remove the hook entries whose command contains `/.claude/hooks/`, or restore the backup the installer made (`settings.json.bak-<date>`).
- Restart Claude Code.

### Update blueprint files later
After you replace this folder with a newer version:
```bash
bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh --dry-run   # preview
bash ~/ailoopwise-blueprint/blueprint/scripts/blueprint-sync.sh             # apply
```
It updates the global install and the projects set up with `/new-project` that it finds up to 3 folder levels below your home folder (use `--depth N` to search deeper, or `--project <folder>` for one project). It never overwrites a file you changed; a blueprint file you deleted comes back unless you list it in `.blueprint-ignore` (see MASTER-BLUEPRINT.md).
