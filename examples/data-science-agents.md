# Example: `/metaskill data science pipeline`

Running `/metaskill data science pipeline` produces:

```
data-science-agents/
├── CLAUDE.md
├── .mcp.json
└── .claude/
    ├── agents/
    │   ├── tech-lead.md         # Opus — orchestrates analysis workflow
    │   ├── data-engineer.md     # Sonnet — ETL, data quality, schemas
    │   ├── ml-engineer.md       # Sonnet — training, evaluation, features
    │   ├── analyst.md           # Sonnet — EDA, visualization, statistics
    │   └── code-reviewer.md     # Sonnet — notebook & pipeline review
    ├── skills/
    │   ├── run-pipeline/SKILL.md
    │   ├── evaluate-model/SKILL.md
    │   └── generate-report/SKILL.md
    └── rules/
        └── python-data-standards.md
```

## Routing Table

| Task Type | Agent | When to Use |
|-----------|-------|-------------|
| Project planning, experiment design | tech-lead | New analysis, pipeline design |
| Data ingestion, cleaning, schemas | data-engineer | ETL, data quality issues |
| Model training, hyperparams, features | ml-engineer | ML tasks |
| EDA, charts, statistical analysis | analyst | Exploration, reporting |
| Code & notebook review | code-reviewer | All changes |
