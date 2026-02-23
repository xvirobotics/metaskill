---
name: run-pipeline
description: "Run the full data science pipeline: validate raw data, preprocess, engineer features, train model, and evaluate. Use this when you want to execute the end-to-end ML pipeline or re-run it after data or code changes."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Grep
argument-hint: "[config-file] e.g. configs/experiment.yaml"
---

You are executing the full data science pipeline for this project. Run each stage sequentially, verifying success before proceeding to the next stage. Stop immediately if any stage fails and report the error clearly.

## Dynamic Context

Current branch: !`git branch --show-current`
Data directory contents: !`ls data/ 2>/dev/null || echo "No data/ directory found"`
Available configs: !`ls configs/*.yaml 2>/dev/null || ls configs/*.toml 2>/dev/null || echo "No config files found"`
Python environment: !`which python3 && python3 --version 2>/dev/null || echo "Python not found"`
Recent changes: !`git diff --stat HEAD~3 2>/dev/null || echo "No recent commits"`

## Configuration

If the user provided a config file as an argument, use it: `$ARGUMENTS`
Otherwise, look for the default config at `configs/experiment.yaml` or `configs/experiment.toml`.

## Pipeline Stages

Execute each stage in order. After each stage, check for errors and verify outputs exist before proceeding.

### Stage 1: Environment Check

Verify the Python environment is ready:

```bash
python3 -c "import torch; import pandas; import numpy; print(f'PyTorch {torch.__version__}, pandas {pandas.__version__}, NumPy {numpy.__version__}')"
```

If imports fail, report which packages are missing and suggest `pip install -r requirements.txt`.

### Stage 2: Data Validation

Run data validation on the raw data:

```bash
python3 -m src.data.validate --data-dir data/raw/
```

If the validation script does not exist, look for alternative patterns:
- `python3 src/data/validate.py`
- `python3 -m pytest tests/test_data/ -v --tb=short`
- Check for pandera schemas in `src/data/` and report their status

Verify: validation passes with no critical errors. Log any warnings.

### Stage 3: Preprocessing

Run the preprocessing pipeline:

```bash
python3 -m src.data.preprocess --config $CONFIG_FILE
```

Alternative patterns:
- `python3 src/data/preprocess.py --config $CONFIG_FILE`
- `dvc repro preprocess` (if DVC pipeline is configured)

Verify: processed data files exist in `data/processed/` (check for `.parquet` or `.csv` files).

### Stage 4: Feature Engineering

Run feature engineering:

```bash
python3 -m src.features.build_features --config $CONFIG_FILE
```

Alternative patterns:
- `python3 src/features/build_features.py`
- `dvc repro features`

Verify: feature files exist in `data/features/` with expected columns.

### Stage 5: Model Training

Run model training:

```bash
python3 -m src.models.training.trainer --config $CONFIG_FILE
```

Alternative patterns:
- `python3 src/models/train.py --config $CONFIG_FILE`
- `python3 train.py --config $CONFIG_FILE`

Monitor output for:
- Loss values (should decrease over epochs)
- Validation metrics at each epoch
- Any NaN or Inf values (indicates numerical instability)
- Out-of-memory errors

Verify: model checkpoint exists in `checkpoints/` directory.

### Stage 6: Evaluation

Run model evaluation on the test set:

```bash
python3 -m src.models.evaluation.evaluate --checkpoint checkpoints/best_model.pt --config $CONFIG_FILE
```

Alternative patterns:
- `python3 src/evaluation/evaluate.py`
- `python3 evaluate.py --checkpoint checkpoints/best_model.pt`

Verify: metrics JSON file exists in `reports/` or `experiments/`.

### Stage 7: Summary

After all stages complete, produce a summary:

1. Report which stages succeeded and which failed
2. Print the final evaluation metrics (read from the metrics JSON)
3. List all generated artifacts (checkpoints, processed data, feature files, metrics)
4. If any stage failed, provide the error message and suggest a fix
5. Report total pipeline execution time

## Error Handling

- If a stage fails, do NOT proceed to the next stage (except validation warnings which are non-blocking)
- Capture stderr and stdout from each command
- For Python errors, read the traceback and identify the root cause
- For file-not-found errors, check if the expected directory structure exists
- For import errors, report the missing package
- For CUDA out-of-memory, suggest reducing batch size in the config
