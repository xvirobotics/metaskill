# Metaskill

![Metaskill: Instant AI Agent Teams for Any Project](resources/image.png)

**One skill to generate them all.**

Metaskill is a suite of [Claude Code](https://claude.ai/code) skills for creating and managing AI agent teams:

| Skill | Purpose |
|-------|---------|
| `/metaskill` | Research a domain, then generate a complete `.claude/` agent team (orchestrator + specialists + skills + rules + MCP) |
| `/create-agent` | Create a single custom Claude Code subagent with well-designed frontmatter and system prompt |
| `/create-skill` | Create a single custom Claude Code skill (slash command) with proper configuration |

```bash
# Generate a full agent team for a project
/metaskill ios app with SwiftUI
/metaskill fullstack web app with React and PostgreSQL
/metaskill data science pipeline with PyTorch
/metaskill game dev with Unity and C#

# Create individual agents and skills
/create-agent security reviewer for Go microservices
/create-skill deploy to staging with Docker
```

`/metaskill` creates a self-contained project with a full AI team inside it. `/create-agent` and `/create-skill` let you add individual components to any existing project.

---

## Skills Overview

### `/metaskill` — Team Generator

Runs in 4 phases (research → build → credentials → verify) to create an entire agent team from scratch. See [How It Works](#how-it-works) below.

### `/create-agent` — Agent Builder

Interactively creates a single `.claude/agents/<name>.md` file. Guides you through:
- Scope selection (project-level vs user-level)
- Expert persona design
- Frontmatter configuration (model, tools, permissions)
- System prompt authoring with self-verification steps

### `/create-skill` — Skill Builder

Interactively creates a single `.claude/skills/<name>/SKILL.md` file. Guides you through:
- Scope and invocation model (user-invocable, auto-invocable, or both)
- Execution context (main conversation vs forked)
- Dynamic context injection with shell commands
- Argument handling and tool access

---

## What Gets Generated

> The following applies to `/metaskill`. For `/create-agent` and `/create-skill`, a single file is generated interactively.

```
ios-app-agents/
├── CLAUDE.md                     ← routing table + orchestration protocol
├── .mcp.json                     ← MCP servers, auto-discovered by Claude Code
└── .claude/
    ├── agents/
    │   ├── tech-lead.md          ← Opus model, routes all tasks
    │   ├── ios-engineer.md       ← SwiftUI, platform APIs
    │   ├── ui-designer.md        ← layouts, animations, design system
    │   ├── test-engineer.md      ← XCTest, UI testing
    │   └── code-reviewer.md      ← quality gate for all code changes
    ├── skills/
    │   ├── build-and-test/SKILL.md
    │   └── run-simulator/SKILL.md
    └── rules/
        └── swift-standards.md
```

After generation:

```bash
cd ios-app-agents
claude
> "Build a SwiftUI todo app with iCloud sync"
```

The `tech-lead` agent breaks the task down and delegates to specialists. You supervise, they build.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/install.sh | bash
```

This installs all three skills (`/metaskill`, `/create-agent`, `/create-skill`) to `~/.claude/skills/`.

Or manually:

```bash
# Install all skills
mkdir -p ~/.claude/skills/{metaskill,create-agent,create-skill}

curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/skill/SKILL.md \
  -o ~/.claude/skills/metaskill/SKILL.md

curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/skills/create-agent/SKILL.md \
  -o ~/.claude/skills/create-agent/SKILL.md

curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/skills/create-skill/SKILL.md \
  -o ~/.claude/skills/create-skill/SKILL.md
```

**Requirements:** [Claude Code](https://claude.ai/code) CLI installed and authenticated.

---

## How It Works

Metaskill runs in 4 phases inside an isolated Claude Code subagent:

```
Phase 1: RESEARCH
  ├── Web search: real-world team structures for your domain
  ├── Web search: existing Claude Code agent configs on GitHub
  ├── Web search: MCP servers relevant to your tech stack
  └── Web search: best practices, linters, testing frameworks

Phase 2: BUILD
  ├── CLAUDE.md          — routing table + orchestration protocol
  ├── .claude/agents/    — 4-6 agents (tech-lead + specialists + reviewer)
  ├── .claude/skills/    — 2-4 workflow automation skills
  ├── .claude/rules/     — coding standards for the primary language
  └── .mcp.json          — MCP server configuration

Phase 3: CREDENTIALS
  └── Asks for any API keys/tokens needed by MCP servers
      (always offers "skip / configure later")

Phase 4: VERIFY
  └── Lists all created files, validates .mcp.json, prints summary
```

The research phase is what makes each generated team genuinely useful — it's not a fixed template. It adapts to what actually matters in your domain right now.

---

## The Idea

Modern AI coding agents are powerful, but setting up a well-structured multi-agent team takes hours: designing roles, writing system prompts, choosing MCP servers, configuring routing. Metaskill automates that entire setup step.

The name is a reference to the philosophical concept of a **meta-skill** — a skill that makes you better at acquiring other skills. In this case: a skill that generates the skills (and agents, and rules) you need to work on any kind of project.

One prompt. One team. Start building.

---

## Agent Architecture

Every generated team follows this pattern:

| Role | Model | Responsibility |
|------|-------|---------------|
| `tech-lead` | Opus | Routes tasks, coordinates agents, never implements directly |
| `<specialist-1>` | Sonnet | Domain expert #1 (e.g. frontend, iOS, data engineering) |
| `<specialist-2>` | Sonnet | Domain expert #2 |
| `<specialist-3>` | Sonnet | Domain expert #3 (optional) |
| `code-reviewer` | Sonnet | Quality gate — all code passes through here |

**Orchestration protocol** (in every generated `CLAUDE.md`):
- Tech-lead is the routing authority
- Main Claude never implements directly for multi-step tasks — it delegates
- Structured handoff documents between agents
- Code reviewer is a mandatory quality gate

---

## MCP Server Catalog

Metaskill selects MCP servers based on your domain. Commonly used:

| Server | Purpose | Transport |
|--------|---------|-----------|
| `context7` | Up-to-date library docs | stdio |
| `playwright` | Browser automation & e2e testing | stdio |
| `filesystem` | Enhanced file operations | stdio |
| `postgres` | Database queries | stdio |
| `sequential-thinking` | Structured multi-step reasoning | stdio |
| `github` | GitHub API access | HTTP |

All servers are written to `.mcp.json` and auto-discovered by Claude Code on launch. No `claude mcp add` needed.

---

## Examples

See the [`examples/`](examples/) directory:

- [Fullstack Web App](examples/fullstack-web-agents.md) — React + Node + PostgreSQL
- [iOS App](examples/ios-app-agents.md) — SwiftUI + XCTest
- [Data Science Pipeline](examples/data-science-agents.md) — Python + PyTorch

---

## Project Structure

| File | Description |
|------|-------------|
| [`skill/SKILL.md`](skill/SKILL.md) | `/metaskill` — the team generator skill |
| [`skills/create-agent/SKILL.md`](skills/create-agent/SKILL.md) | `/create-agent` — single agent builder |
| [`skills/create-skill/SKILL.md`](skills/create-skill/SKILL.md) | `/create-skill` — single skill builder |
| [`install.sh`](install.sh) | Installer for all three skills |
| [`examples/`](examples/) | Example generated outputs |

---

## Contributing

PRs welcome. Each skill is a single markdown file — edit directly and test.

To improve:
1. Fork the repo
2. Edit the relevant `SKILL.md`
3. Test in Claude Code (`/metaskill`, `/create-agent`, or `/create-skill`)
4. Submit a PR with a before/after example

---

## Citation

If you use Metaskill in research, please cite:

```bibtex
@software{sung2025metaskill,
  author  = {Sung, Flood},
  title   = {Metaskill: A Meta-Skill for Autonomous AI Agent Team Generation},
  year    = {2025},
  url     = {https://github.com/xvirobotics/metaskill},
  license = {MIT}
}
```

A `CITATION.cff` file is also provided for GitHub's "Cite this repository" button.

---

## License

MIT © [XVI Robotics](https://github.com/xvirobotics)
