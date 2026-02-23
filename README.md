# Metaskill

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/xvirobotics/metaskill?style=social)](https://github.com/xvirobotics/metaskill)

![Metaskill: Instant AI Agent Teams for Any Project](resources/image.png)

**One skill to create them all.**

Metaskill is a [Claude Code](https://claude.ai/code) skill that creates AI agent teams, individual agents, and custom skills — all through a single `/metaskill` command.

```bash
# Generate a full agent team for a project
/metaskill ios app with SwiftUI
/metaskill fullstack web app with React and PostgreSQL
/metaskill data science pipeline with PyTorch
/metaskill game dev with Unity and C#

# Create a single agent
/metaskill a security reviewer agent for Go microservices
/metaskill a code reviewer agent

# Create a single skill
/metaskill a deploy-to-staging skill with Docker
/metaskill a lint-and-format skill
```

One command. It detects your intent and routes to the right flow automatically.

---

## What It Does

### Team Generation (default)

When you describe a project type, Metaskill runs a 4-phase process:

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

### Single Agent Creation

When your request mentions "agent", "reviewer", or a specific role, Metaskill creates a single `.claude/agents/<name>.md` with:
- Expert persona design
- Frontmatter configuration (model, tools, permissions)
- System prompt with self-verification and Workflow Discipline built in

### Single Skill Creation

When your request mentions "skill", "command", or "slash command", Metaskill creates a single `.claude/skills/<name>/SKILL.md` with:
- Scope and invocation model configuration
- Dynamic context injection
- Argument handling and tool access

---

## What Gets Generated (Team Mode)

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

This installs `/metaskill` to `~/.claude/skills/metaskill/`.

Or manually:

```bash
mkdir -p ~/.claude/skills/metaskill/flows

curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/skill/SKILL.md \
  -o ~/.claude/skills/metaskill/SKILL.md

curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/skill/flows/team.md \
  -o ~/.claude/skills/metaskill/flows/team.md

curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/skill/flows/agent.md \
  -o ~/.claude/skills/metaskill/flows/agent.md

curl -fsSL https://raw.githubusercontent.com/xvirobotics/metaskill/main/skill/flows/skill.md \
  -o ~/.claude/skills/metaskill/flows/skill.md
```

**Requirements:** [Claude Code](https://claude.ai/code) CLI installed and authenticated.

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
- All agents follow built-in Workflow Discipline: plan-first, re-plan on failure, verify before done, autonomous execution

---

## MCP Server Catalog

Metaskill selects MCP servers based on your domain. Verified catalog:

| Server | Package | Purpose | Transport |
|--------|---------|---------|-----------|
| `context7` | `@upstash/context7-mcp@latest` | Up-to-date library docs | stdio |
| `playwright` | `@playwright/mcp@latest` | Browser automation & e2e testing | stdio |
| `filesystem` | `@modelcontextprotocol/server-filesystem` | Enhanced file operations | stdio |
| `postgres` | `@modelcontextprotocol/server-postgres` | Database queries | stdio |
| `sequential-thinking` | `@modelcontextprotocol/server-sequential-thinking` | Structured multi-step reasoning | stdio |
| `memory` | `@modelcontextprotocol/server-memory` | Persistent knowledge graph | stdio |
| `github` | `https://api.githubcopilot.com/mcp/` | GitHub API access | HTTP |

All servers are written to `.mcp.json` and auto-discovered by Claude Code on launch. No `claude mcp add` needed.

---

## Examples

The [`examples/`](examples/) directory contains **real, usable agent teams** generated by Metaskill. Each is a complete project you can copy and use directly:

| Example | Stack | Agents | Skills |
|---------|-------|--------|--------|
| [`fullstack-web/`](examples/fullstack-web/) | React + Node.js + PostgreSQL | tech-lead, frontend-engineer, backend-engineer, devops-engineer, code-reviewer | build-and-test, deploy-preview, api-test |
| [`ios-app/`](examples/ios-app/) | SwiftUI + Swift | tech-lead, ios-engineer, ui-designer, test-engineer, code-reviewer | build-and-test, run-simulator |
| [`data-science/`](examples/data-science/) | Python + PyTorch | tech-lead, data-engineer, ml-engineer, analyst, code-reviewer | run-pipeline, evaluate-model, generate-report |

Try one:
```bash
cp -r examples/fullstack-web my-project
cd my-project && claude
```

---

## Project Structure

```
metaskill/
├── skill/
│   ├── SKILL.md              ← /metaskill entry point (intent routing)
│   └── flows/
│       ├── team.md           ← full agent team generation flow
│       ├── agent.md          ← single agent creation flow
│       └── skill.md          ← single skill creation flow
├── install.sh                ← installer
└── examples/                 ← example generated outputs
```

---

## Contributing

PRs welcome. The skill is modular — edit the specific flow file for what you want to improve:

1. Fork the repo
2. Edit the relevant file in `skill/flows/`
3. Test in Claude Code with `/metaskill`
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
