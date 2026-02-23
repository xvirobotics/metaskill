# CLAUDE.md

## Project Overview

This is a Python data science and machine learning pipeline project built on PyTorch. The project follows a structured ML lifecycle: raw data ingestion, data validation, preprocessing, feature engineering, model training, evaluation, and reporting. The codebase is organized for reproducibility, modularity, and production readiness.

### Tech Stack
- **Language:** Python 3.10+
- **ML Framework:** PyTorch (with torchvision, torchaudio as needed)
- **Data Processing:** pandas, polars, NumPy
- **Data Validation:** pandera, Great Expectations
- **Experiment Tracking:** MLflow, Weights & Biases
- **Hyperparameter Tuning:** Optuna
- **Visualization:** matplotlib, seaborn, plotly
- **Data Format:** Parquet, Arrow (via pyarrow)
- **Analytics:** DuckDB
- **Model Export:** ONNX
- **Data Versioning:** DVC
- **Environment:** pyproject.toml with pip or Poetry

### Project Structure
```
data/
  raw/              # Immutable raw data
  processed/        # Cleaned and transformed data
  features/         # Engineered feature sets
src/
  data/             # Data loading, validation, preprocessing
  features/         # Feature engineering pipelines
  models/           # Model definitions, training loops
  evaluation/       # Metrics, evaluation scripts
  utils/            # Shared utilities, logging, config
notebooks/          # EDA and analysis notebooks
configs/            # YAML/TOML experiment configs
experiments/        # MLflow/W&B experiment logs
checkpoints/       # Model checkpoints
reports/            # Generated reports, plots, metrics summaries
tests/              # Unit and integration tests
```

## Agent Team

### Routing Table

| Task Type | Agent | When to Use |
|-----------|-------|-------------|
| Feature planning, task breakdown, delegation | tech-lead | Any new feature, complex task, or cross-cutting concern |
| Data ingestion, ETL pipelines, schema design, data validation | data-engineer | Working with raw data, building pipelines, data quality issues |
| Model architecture, training loops, hyperparameter tuning, evaluation | ml-engineer | Building or modifying models, training runs, optimization |
| EDA, statistical analysis, visualization, reporting | analyst | Exploratory analysis, generating reports, interpreting results |
| Code review, ML-specific review (data leakage, reproducibility) | code-reviewer | All code changes before merge |

### Orchestration Protocol

1. **Tech-lead is the routing authority.** When a complex task arrives, the tech-lead agent analyzes it and delegates to the appropriate specialist(s). The tech-lead understands the full ML lifecycle and knows which agent owns each stage.
2. **Main agent never implements directly** for multi-step tasks -- it delegates to specialists via the Task tool. Each delegation includes: (a) clear objective, (b) relevant file paths, (c) acceptance criteria, (d) which agent to hand off to next.
3. **Pipeline order matters.** Data tasks must complete before model tasks. The tech-lead enforces this dependency: data-engineer validates and prepares data before ml-engineer trains on it.
4. **Max 2 agents in parallel** for complex tasks to avoid file conflicts. Data-engineer and analyst can work in parallel (different file domains), but ml-engineer should wait for data-engineer to finish.
5. **Code reviewer is the quality gate** -- all code changes pass through code-reviewer before completion. The reviewer checks for ML-specific issues: data leakage, reproducibility, numerical stability.

### Workflow Chains

- **Data Pipeline**: tech-lead --> data-engineer (ingest + validate + preprocess) --> code-reviewer
- **Feature Engineering**: tech-lead --> data-engineer (build features) --> analyst (validate feature distributions) --> code-reviewer
- **Model Training**: tech-lead --> ml-engineer (architecture + training + evaluation) --> code-reviewer
- **Full Pipeline**: tech-lead --> data-engineer --> ml-engineer --> analyst (report) --> code-reviewer
- **Analysis Report**: tech-lead --> analyst (EDA + visualization + narrative) --> code-reviewer
- **Bug Fix**: tech-lead --> [appropriate specialist] --> code-reviewer
- **Experiment Iteration**: tech-lead --> ml-engineer (tune hyperparams) --> analyst (compare results) --> tech-lead (decide next step)

## Coding Standards

### Python Conventions
- **PEP 8** compliance enforced via ruff or flake8
- **Type hints** on all function signatures and class attributes (use `from __future__ import annotations`)
- **Google-style docstrings** on all public functions, classes, and modules
- **Black** or **ruff format** for code formatting (line length: 88)
- **isort** for import ordering (profile: black)

### ML-Specific Standards
- **Reproducibility:** Seed all random sources (Python `random`, NumPy, PyTorch, CUDA) at the top of every script via a shared `set_seed(seed: int)` utility
- **Configuration over code:** All hyperparameters, paths, and experiment settings live in YAML/TOML config files, never hardcoded
- **Data/code separation:** Raw data is never modified. Processed data is generated by reproducible scripts. Data paths are relative or configurable
- **No hardcoded paths:** Use `pathlib.Path` and config files for all file paths
- **Virtual environments:** Always use a virtual environment. Dependencies pinned in `pyproject.toml` with a lockfile
- **Logging over print:** Use Python `logging` module, never bare `print()` in library code
- **Device-agnostic code:** Always use `device = torch.device("cuda" if torch.cuda.is_available() else "cpu")` and pass device explicitly

### Testing
- **pytest** for all tests
- Unit tests for data transformations, feature engineering, and utility functions
- Integration tests for end-to-end pipeline runs on small fixture data
- Model tests: verify forward pass shapes, gradient flow, checkpoint save/load roundtrip

### Version Control
- **DVC** for large data files and model checkpoints (never commit large binaries to git)
- `.gitignore` covers: `data/raw/`, `data/processed/`, `checkpoints/`, `experiments/`, `__pycache__/`, `.venv/`
- Meaningful commit messages referencing experiment IDs when relevant

## Workflow Discipline (All Agents)

### Planning
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately -- don't keep pushing
- Write detailed specs upfront to reduce ambiguity

### Autonomous Execution
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests -- then resolve them
- Zero context switching required from the user

### Verification
- Never mark a task complete without proving it works
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### Self-Improvement
- After ANY correction from the user: record the pattern as a lesson
- Write rules for yourself that prevent the same mistake
- Review lessons at session start for relevant context

### Core Principles
- **Simplicity First**: Make every change as simple as possible. Minimal code impact.
- **Root Cause Focus**: Find root causes. No temporary fixes.
- **Minimal Footprint**: Only touch what's necessary. Avoid introducing bugs.
- **Demand Elegance**: For non-trivial changes, pause and ask "is there a more elegant way?" Skip for simple fixes.
- **Subagent Strategy**: Use subagents liberally. One tack per subagent for focused execution.

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Run Pipeline | `/run-pipeline` | Runs the full data pipeline: validate data, preprocess, engineer features, train model, evaluate |
| Evaluate Model | `/evaluate-model` | Loads latest model checkpoint, runs evaluation on test set, generates metrics and confusion matrix |
| Generate Report | `/generate-report` | Generates a summary report of the latest experiment with metrics, plots, and baseline comparison |
