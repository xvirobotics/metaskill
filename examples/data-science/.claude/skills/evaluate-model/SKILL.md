---
name: evaluate-model
description: "Load the latest model checkpoint, run evaluation on the test set, and generate a metrics report with confusion matrix. Use this after training to assess model performance or to re-evaluate a specific checkpoint."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Grep, Write
argument-hint: "[checkpoint-path] e.g. checkpoints/best_model.pt"
---

You are running model evaluation for this project. Your goal is to load a trained model checkpoint, evaluate it on the held-out test set, compute comprehensive metrics, and generate a structured report.

## Dynamic Context

Current branch: !`git branch --show-current`
Available checkpoints: !`ls checkpoints/*.pt checkpoints/*.pth 2>/dev/null || echo "No checkpoints found"`
Test data: !`ls data/processed/test* data/features/test* 2>/dev/null || echo "No test data found"`
Latest metrics: !`ls -t reports/*.json experiments/*.json 2>/dev/null | head -3 || echo "No previous metrics found"`
Config files: !`ls configs/*.yaml configs/*.toml 2>/dev/null || echo "No configs found"`

## Checkpoint Selection

If the user provided a checkpoint path as an argument, use it: `$ARGUMENTS`

Otherwise, find the latest checkpoint:
1. Look for `checkpoints/best_model.pt` or `checkpoints/best_model.pth`
2. If not found, find the most recently modified `.pt` or `.pth` file in `checkpoints/`
3. If no checkpoints exist, report the error and stop

## Evaluation Process

### Step 1: Load and Verify Checkpoint

Verify the checkpoint file exists and can be loaded:

```bash
python3 -c "
import torch
ckpt = torch.load('$CHECKPOINT_PATH', map_location='cpu', weights_only=False)
print('Checkpoint keys:', list(ckpt.keys()))
print('Epoch:', ckpt.get('epoch', 'unknown'))
print('Best metric:', ckpt.get('best_metric', 'unknown'))
print('Config:', ckpt.get('config', 'not stored'))
"
```

Report the checkpoint metadata: epoch, stored metric, config used.

### Step 2: Run Evaluation Script

Execute the evaluation:

```bash
python3 -m src.models.evaluation.evaluate \
    --checkpoint $CHECKPOINT_PATH \
    --data-dir data/features/ \
    --output-dir reports/ \
    --config configs/experiment.yaml
```

Alternative patterns to try if the above fails:
- `python3 src/evaluation/evaluate.py --checkpoint $CHECKPOINT_PATH`
- `python3 evaluate.py --checkpoint $CHECKPOINT_PATH --test-data data/features/test.parquet`

### Step 3: Collect Metrics

After evaluation completes, read the metrics output. Look for the metrics JSON file:

```bash
cat reports/metrics.json 2>/dev/null || cat reports/evaluation_metrics.json 2>/dev/null
```

If no JSON file was generated, parse metrics from the script's stdout.

### Step 4: Generate Confusion Matrix

If the evaluation script did not generate a confusion matrix plot, create one:

```bash
python3 -c "
import json
import numpy as np
from pathlib import Path

# Load metrics that include confusion matrix data
metrics_path = Path('reports/metrics.json')
if metrics_path.exists():
    metrics = json.loads(metrics_path.read_text())
    if 'confusion_matrix' in metrics:
        cm = np.array(metrics['confusion_matrix'])
        print('Confusion Matrix:')
        print(cm)
        print()
        # Print per-class metrics
        for i, row in enumerate(cm):
            precision = row[i] / max(row.sum(), 1)
            recall = row[i] / max(cm[:, i].sum(), 1)
            print(f'Class {i}: Precision={precision:.4f}, Recall={recall:.4f}')
"
```

### Step 5: Compare with Baseline

If previous metrics exist, load and compare:

1. Find the most recent previous metrics file (excluding the one just generated)
2. Compute deltas for each metric
3. Flag any metric regressions (where current is worse than previous)
4. Highlight improvements

### Step 6: Generate Summary Report

Produce a structured evaluation report:

```markdown
## Model Evaluation Report

### Checkpoint
- Path: [checkpoint path]
- Epoch: [epoch number]
- Training config: [config file used]

### Test Set Metrics
| Metric | Value |
|--------|-------|
| Accuracy | X.XXXX |
| Precision (macro) | X.XXXX |
| Recall (macro) | X.XXXX |
| F1 (macro) | X.XXXX |
| AUC-ROC | X.XXXX |

### Confusion Matrix
[confusion matrix table or reference to plot]

### Comparison with Previous Run
| Metric | Previous | Current | Delta |
|--------|----------|---------|-------|
| ... | ... | ... | +/- ... |

### Observations
- [Key findings about model performance]
- [Any concerning patterns in errors]
- [Recommendations for improvement]
```

Write this report to `reports/evaluation_report.md`.

## Error Handling

- If checkpoint cannot be loaded: check for PyTorch version mismatch, report the error
- If test data is missing: report which files are expected and where to find them
- If CUDA is not available: run evaluation on CPU (will be slower but should work)
- If metrics computation fails: report the specific error and which metric caused it
