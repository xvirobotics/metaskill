# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- CONTRIBUTING.md with contribution guide
- Issue templates (bug report + feature request)
- CHANGELOG.md
- README badges (license, stars)
- GitHub Topics for discoverability

## [1.1.0] - 2025-02-19

### Added
- `/create-agent` skill for creating individual custom agents
- `/create-skill` skill for creating individual custom skills

### Fixed
- MCP server package names corrected to use verified real packages
- Removed references to non-existent @anthropic-ai/mcp-* packages

## [1.0.0] - 2025-02-18

### Added
- `/metaskill` — autonomous AI agent team generator
- 4-phase workflow: Research → Build → Credentials → Verify
- Generates complete `.claude/` directory with agents, skills, rules
- MCP server auto-configuration (.mcp.json)
- Agent architecture: tech-lead (Opus) + specialists (Sonnet) + code-reviewer
- 3 example outputs: iOS app, fullstack web, data science
- One-line installer script (install.sh)
- MIT license
