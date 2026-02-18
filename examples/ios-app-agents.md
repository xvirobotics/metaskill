# Example: `/metaskill ios app with SwiftUI`

Running `/metaskill ios app with SwiftUI` produces:

```
ios-app-agents/
├── CLAUDE.md
├── .mcp.json
└── .claude/
    ├── agents/
    │   ├── tech-lead.md         # Opus — orchestrates all tasks
    │   ├── ios-engineer.md      # Sonnet — SwiftUI, platform APIs
    │   ├── ui-designer.md       # Sonnet — layout, animations, design system
    │   ├── test-engineer.md     # Sonnet — XCTest, UI testing
    │   └── code-reviewer.md     # Sonnet — Swift quality gate
    ├── skills/
    │   ├── build-and-test/SKILL.md
    │   ├── run-simulator/SKILL.md
    │   └── review-checklist/SKILL.md
    └── rules/
        └── swift-standards.md
```

## Routing Table

| Task Type | Agent | When to Use |
|-----------|-------|-------------|
| Feature planning, architecture decisions | tech-lead | New features, refactors |
| SwiftUI views, data flow, networking | ios-engineer | Core app development |
| Layout, animations, design tokens | ui-designer | UI/UX implementation |
| Unit tests, UI tests, test plans | test-engineer | Testing and QA |
| Code review | code-reviewer | All changes before merge |
