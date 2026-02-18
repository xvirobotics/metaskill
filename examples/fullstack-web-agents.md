# Example: `/metaskill fullstack web app`

Running `/metaskill fullstack web app` in an empty directory produces:

```
fullstack-web-agents/
├── CLAUDE.md
├── .mcp.json
└── .claude/
    ├── agents/
    │   ├── tech-lead.md          # Opus — orchestrates all tasks
    │   ├── frontend-engineer.md  # Sonnet — React/Vue, CSS, a11y
    │   ├── backend-engineer.md   # Sonnet — APIs, DB, auth
    │   ├── devops-engineer.md    # Sonnet — Docker, CI/CD, infra
    │   └── code-reviewer.md      # Sonnet — quality gate
    ├── skills/
    │   ├── build-and-test/SKILL.md
    │   ├── deploy-preview/SKILL.md
    │   └── review-checklist/SKILL.md
    └── rules/
        └── typescript-standards.md
```

## CLAUDE.md Routing Table

| Task Type | Agent | When to Use |
|-----------|-------|-------------|
| Feature planning, task breakdown | tech-lead | Any new feature or complex task |
| UI components, styling, client logic | frontend-engineer | React/Vue work, CSS, accessibility |
| APIs, database, server logic | backend-engineer | REST/GraphQL, auth, DB migrations |
| CI/CD, Docker, deployment | devops-engineer | Infrastructure, pipeline changes |
| Code review, PR review | code-reviewer | All code changes before merge |

## .mcp.json

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {}
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-playwright"],
      "env": {}
    }
  }
}
```

## What Happens Next

```
cd fullstack-web-agents
claude
> "Build a todo app with user auth"
```

The tech-lead agent receives the task, breaks it down, delegates backend work to backend-engineer, frontend to frontend-engineer, and routes the final code through code-reviewer.
