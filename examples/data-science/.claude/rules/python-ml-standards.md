# Python & Machine Learning Coding Standards

These standards apply to all Python code in this project. Agents and reviewers must enforce these rules consistently.

## Python Style

### PEP 8 Compliance
- Follow PEP 8 naming conventions strictly:
  - `snake_case` for functions, methods, variables, and module names
  - `PascalCase` for class names
  - `UPPER_SNAKE_CASE` for module-level constants
  - `_leading_underscore` for private attributes and methods
- Maximum line length: 88 characters (Black default)
- Use `ruff` or `black` for formatting, `isort` (profile: black) for import ordering
- Two blank lines before top-level definitions, one blank line before methods

### Type Hints
- Every function signature must have type hints for all parameters and the return type
- Use `from __future__ import annotations` at the top of every module for modern syntax (PEP 604 unions `X | None`, PEP 585 generics `list[int]`)
- Use `typing` module only for constructs not yet available as builtins (e.g., `TypeVar`, `Protocol`, `Literal`)
- Annotate class attributes in `__init__` or use dataclass/Pydantic fields
- For NumPy arrays, use `np.ndarray` (or `npt.NDArray[np.float32]` for precision)
- For PyTorch tensors, use `torch.Tensor`
- For pandas DataFrames, use `pd.DataFrame` or pandera `DataFrame[Schema]`

### Docstrings (Google Style)
- Every public function, class, and module must have a docstring
- Use Google-style format:
  ```python
  def train_epoch(
      model: nn.Module,
      dataloader: DataLoader,
      optimizer: torch.optim.Optimizer,
      device: torch.device,
  ) -> float:
      """Train the model for one epoch.

      Runs a full pass over the training dataloader, computing loss
      and updating model weights.

      Args:
          model: The PyTorch model to train.
          dataloader: Training data loader.
          optimizer: The optimizer instance.
          device: Device to run training on (cpu or cuda).

      Returns:
          Average training loss for the epoch.

      Raises:
          RuntimeError: If a NaN loss is detected.
      """
  ```
- Include `Args`, `Returns`, `Raises` sections as applicable
- First line is a concise summary (imperative mood: "Train the model", not "Trains the model")
- Omit docstrings only for truly trivial private helper functions

### Imports
- Order: standard library, blank line, third-party, blank line, local/project
- Use absolute imports: `from src.data.validate import RawDataSchema`
- Never use wildcard imports: `from module import *`
- Group related imports but keep each import on its own line for merge-friendliness

## Reproducibility Requirements

### Random Seed Protocol
- Every training entry point must call `set_seed(seed)` before any other operation
- The `set_seed` function must set: `random.seed()`, `np.random.seed()`, `torch.manual_seed()`, `torch.cuda.manual_seed_all()`, `os.environ["PYTHONHASHSEED"]`
- For fully deterministic training, also set `torch.backends.cudnn.deterministic = True` and `torch.backends.cudnn.benchmark = False`
- The seed value must come from the config file, never hardcoded

### Configuration Over Code
- All hyperparameters, file paths, and experiment settings must live in YAML or TOML config files
- Use Pydantic `BaseModel` or `@dataclass` to parse and validate config files with type checking
- Never hardcode: learning rate, batch size, number of epochs, model dimensions, file paths, data splits, random seeds
- Config files are committed to git alongside code for full experiment reproducibility

### Experiment Tracking
- Every training run must log to MLflow or W&B: parameters, per-epoch metrics, final metrics, artifacts
- Include git commit hash in experiment metadata
- Include dataset version (DVC hash or explicit version tag) in experiment metadata

## Data / Code Separation

### File Paths
- Use `pathlib.Path` for all file path operations, never `os.path.join()` or string concatenation
- All paths must be configurable via config files or CLI arguments
- Use relative paths in configs, resolved against a `project_root` at runtime
- Never hardcode absolute paths

### Data Immutability
- Raw data in `data/raw/` is read-only -- never modify it programmatically
- All transformations produce new files in `data/processed/` or `data/features/`
- Processed data must be regenerable from raw data + code (no manual steps)

### Large File Management
- Data files, model checkpoints, and experiment artifacts must not be committed to git
- Use DVC for versioning large files
- `.gitignore` must include: `data/raw/`, `data/processed/`, `data/features/`, `checkpoints/`, `experiments/`, `*.pt`, `*.pth`, `*.onnx`, `__pycache__/`, `.venv/`

## PyTorch-Specific Standards

### Device Management
- Create device once at the entry point: `device = torch.device("cuda" if torch.cuda.is_available() else "cpu")`
- Pass `device` explicitly to functions that need it -- never call `.cuda()` directly inside model code
- Use `.to(device)` for moving tensors and models

### Memory Management
- All evaluation and inference code must use `torch.no_grad()` or `torch.inference_mode()`
- Convert tensors to numpy with `.detach().cpu().numpy()`, never skip `.detach()`
- Use `del` and `torch.cuda.empty_cache()` when explicitly freeing large tensors in training loops

### Numerical Stability
- Use `nn.CrossEntropyLoss` instead of manual softmax + log + NLL
- Use `torch.logsumexp` instead of `torch.log(torch.sum(torch.exp(...)))`
- Add epsilon to denominators in custom losses: `/ (denominator + 1e-8)`
- Use gradient clipping for RNNs and Transformers

## Testing Requirements

### Framework
- Use `pytest` for all tests
- Use `tmp_path` fixture for tests that create files
- Use `pytest.fixture` for shared test data (small DataFrames, sample tensors)
- Use `pytest.mark.parametrize` for testing multiple cases

### What to Test
- Data validation schemas: valid input passes, invalid input raises `SchemaError`
- Preprocessing functions: known input produces expected output
- Model forward pass: correct output shapes for given input shapes
- Checkpoint roundtrip: save and load produces identical model state
- Loss functions: correct computation on simple known cases
- Full pipeline: end-to-end run on fixture data (10-100 rows)

### Test Organization
```
tests/
  test_data/           # Data loading, validation, preprocessing tests
  test_features/       # Feature engineering tests
  test_models/         # Model architecture and training tests
  test_evaluation/     # Metric computation and evaluation tests
  conftest.py          # Shared fixtures
```

## Virtual Environment

- Always use a virtual environment (venv, conda, or Poetry)
- Pin dependencies in `pyproject.toml` with minimum version constraints
- Generate a lockfile (`poetry.lock`, `pip-compile` output, or `uv.lock`) for exact reproducibility
- Include PyTorch installation with appropriate CUDA version in setup instructions

## Logging

- Use Python `logging` module, never bare `print()` in library code
- `print()` is acceptable only in CLI entry points and notebooks
- Configure logging at the entry point with format: `%(asctime)s - %(name)s - %(levelname)s - %(message)s`
- Use appropriate log levels: DEBUG for tensor shapes and intermediate values, INFO for stage completion and metrics, WARNING for recoverable issues, ERROR for failures
