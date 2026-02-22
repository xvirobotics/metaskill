# Contributing to Metaskill

Thanks for your interest in contributing! This guide will help you get started.

## Project Structure

```
skill/
  SKILL.md              # /metaskill — the main team generator skill
skills/
  create-agent/SKILL.md # /create-agent — single agent creator
  create-skill/SKILL.md # /create-skill — single skill creator
examples/               # Example generated outputs
```

## How to Contribute

### Reporting Bugs

- Use the [Bug Report](https://github.com/xvirobotics/metaskill/issues/new?template=bug_report.md) template
- Include what you tried to generate and what went wrong

### Suggesting Features

- Use the [Feature Request](https://github.com/xvirobotics/metaskill/issues/new?template=feature_request.md) template
- New agent team templates, MCP server integrations, and skill improvements are all welcome

### Submitting Pull Requests

1. Fork the repo and create a branch from `main`
2. Make your changes — skills are pure Markdown, no build step needed
3. Test by installing locally: `cp -r skill/ ~/.claude/skills/metaskill/`
4. Run the skill in Claude Code to verify it works
5. Open a PR with a clear description

### Areas We'd Love Help With

- **New example templates** — More domain-specific agent team examples
- **MCP server catalog** — Adding new verified MCP server configurations
- **Skill improvements** — Better prompts, more robust generation
- **Documentation** — Tutorials, use case guides, translations

## Testing

Since skills are Markdown-based, testing is manual:

```bash
# Install locally
./install.sh

# Then in Claude Code, run:
# /metaskill
# /create-agent
# /create-skill
```

## Questions?

Open an issue — we're happy to help!
