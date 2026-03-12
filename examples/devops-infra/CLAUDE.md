# CLAUDE.md

## Project Overview

This is a DevOps and Infrastructure project managing cloud infrastructure, container orchestration, CI/CD pipelines, and observability. The project uses Terraform for infrastructure as code (IaC), Docker and Kubernetes for containerized deployments, GitHub Actions for CI/CD automation, and Prometheus with Grafana for monitoring and alerting. The codebase follows a modular, environment-aware structure with separate configurations for dev, staging, and production.

### Tech Stack
- **IaC:** Terraform (with modules), Pulumi (TypeScript/Python where needed)
- **Containers:** Docker, Docker Compose
- **Orchestration:** Kubernetes, Helm charts
- **CI/CD:** GitHub Actions, ArgoCD for GitOps
- **Monitoring:** Prometheus, Grafana, Alertmanager
- **Logging:** Loki, Fluentd/Fluent Bit
- **Cloud:** AWS / GCP / Azure (provider-agnostic module design)
- **Secrets:** HashiCorp Vault, SOPS, sealed-secrets
- **Policy:** Open Policy Agent (OPA), Checkov, tfsec

### Project Structure
```
terraform/
  modules/            # Reusable Terraform modules
    networking/
    compute/
    database/
    iam/
  environments/       # Per-environment configurations
    dev/
    staging/
    production/
  backends/           # Remote state backend configs
kubernetes/
  base/               # Base Kustomize manifests
  overlays/           # Environment-specific overlays
    dev/
    staging/
    production/
  helm-charts/        # Custom Helm charts
docker/
  services/           # Dockerfiles per service
  docker-compose.yml  # Local development stack
.github/
  workflows/          # GitHub Actions CI/CD pipelines
monitoring/
  prometheus/         # Prometheus config and rules
  grafana/            # Grafana dashboards (JSON)
  alertmanager/       # Alertmanager routes and receivers
scripts/              # Automation and helper scripts
docs/                 # Runbooks, architecture diagrams, ADRs
```

## Agent Team

### Routing Table

| Task Type | Agent | When to Use |
|-----------|-------|-------------|
| Task breakdown, architecture decisions, cross-cutting infra planning | `tech-lead` | Any new infrastructure request, multi-step task, or when the best approach is unclear |
| Terraform/Pulumi modules, cloud resources, networking, IAM, state management | `infra-engineer` | Writing or modifying IaC, provisioning cloud resources, managing remote state, module refactors |
| Docker, Kubernetes manifests, Helm charts, container builds, service mesh | `platform-engineer` | Container images, K8s deployments/services/ingress, Helm values, Kustomize overlays, scaling configs |
| GitHub Actions workflows, build pipelines, release automation, GitOps | `cicd-engineer` | CI/CD pipeline creation, workflow debugging, artifact publishing, deployment triggers, ArgoCD sync |
| Prometheus rules, Grafana dashboards, alerting, logging, SLOs, incident response | `sre-engineer` | Monitoring setup, alert tuning, dashboard creation, incident runbooks, SLI/SLO definitions |
| Code review, IaC review, security review, policy compliance | `code-reviewer` | All infrastructure changes before merge, Terraform plan review, K8s manifest validation |

### Orchestration Protocol

1. **Tech-lead is the routing authority.** When a complex infrastructure task arrives, the tech-lead agent analyzes it, breaks it into IaC/platform/pipeline/monitoring subtasks, and delegates to the appropriate specialist(s). The tech-lead never writes infrastructure code directly.
2. **Main agent never implements directly** for multi-step tasks -- it delegates to specialists via the Task tool. Single-file trivial edits (e.g., bumping a version) may be handled directly.
3. **Handoff format:** When delegating, provide: (a) clear objective, (b) relevant file paths and environment context (dev/staging/prod), (c) acceptance criteria, (d) which agent to hand off to next.
4. **Max 2 agents in parallel** for complex tasks to avoid conflicts in shared Terraform state or overlapping K8s manifests. Infra-engineer and cicd-engineer can often work in parallel (different file domains).
5. **Code reviewer is the quality gate** -- all infrastructure changes pass through code-reviewer before completion. The reviewer checks for security misconfigurations, IaC best practices, and blast radius.

### Workflow Chains

- **New Infrastructure**: tech-lead --> infra-engineer (Terraform modules + resources) --> sre-engineer (monitoring for new resources) --> code-reviewer
- **New Service Deployment**: tech-lead --> platform-engineer (Dockerfile + K8s manifests) --> cicd-engineer (pipeline for new service) --> sre-engineer (dashboards + alerts) --> code-reviewer
- **CI/CD Pipeline**: tech-lead --> cicd-engineer (workflow definition) --> code-reviewer
- **Incident Response**: tech-lead (triage) --> sre-engineer (investigate + mitigate) --> infra-engineer or platform-engineer (root cause fix) --> code-reviewer
- **Environment Promotion**: tech-lead --> infra-engineer (plan for target env) --> cicd-engineer (promotion pipeline) --> code-reviewer (review plan output)
- **Security Hardening**: tech-lead --> code-reviewer (audit current state) --> infra-engineer (IAM + network fixes) --> platform-engineer (pod security + network policies) --> code-reviewer (verify fixes)
- **Migration**: tech-lead (plan) --> code-reviewer (review plan) --> infra-engineer (execute) --> sre-engineer (verify health) --> code-reviewer (final review)
- **Monitoring Setup**: tech-lead --> sre-engineer (metrics + dashboards + alerts) --> code-reviewer

## Coding Standards

### Terraform
- **File naming:** `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `data.tf`, `locals.tf` per module
- **Resource naming:** `snake_case` for resource names, descriptive labels matching cloud naming conventions
- **Variables:** Always include `description` and `type`. Use `validation` blocks for constraints. Provide sensible `default` values where safe
- **Modules:** Pin module versions explicitly (`source = "git::...?ref=v1.2.3"`). No floating tags
- **State:** Remote backend with state locking (S3+DynamoDB or GCS). One state file per environment
- **Formatting:** `terraform fmt` on all files. Enforced in CI
- **Plans before applies:** Never `terraform apply` without reviewing the plan. CI generates plan artifacts for review
- **No hardcoded values:** All environment-specific values via `tfvars` files or workspace variables

### Kubernetes
- **Manifests:** Use Kustomize for environment overlays. Helm for third-party charts
- **Labels:** All resources must include `app.kubernetes.io/name`, `app.kubernetes.io/version`, `app.kubernetes.io/managed-by`
- **Resource limits:** Every container must declare `resources.requests` and `resources.limits`
- **Security:** No containers run as root. Use `securityContext` with `runAsNonRoot: true` and `readOnlyRootFilesystem: true`
- **Namespaces:** One namespace per service or bounded context. Never deploy to `default`
- **Probes:** All deployments must have `livenessProbe` and `readinessProbe` configured
- **Secrets:** Never commit plaintext secrets. Use sealed-secrets, SOPS, or external secrets operator

### Docker
- **Multi-stage builds:** Separate build and runtime stages to minimize image size
- **Base images:** Use official, versioned images (e.g., `node:20-alpine`, not `node:latest`)
- **No root:** Final stage runs as non-root user
- **Layer ordering:** Copy dependency manifests first, install, then copy source code (cache optimization)
- **`.dockerignore`:** Always present, excluding `.git`, `node_modules`, build artifacts

### CI/CD Pipelines
- **Pipeline as code:** All pipelines defined in `.github/workflows/` — no manual CI configuration
- **Idempotent steps:** Every pipeline step must be safe to re-run
- **Secrets via GitHub Secrets:** Never hardcode tokens or keys in workflow files
- **Branch protection:** `main` requires passing CI + code review before merge
- **Artifact versioning:** Use semantic versioning for releases and container image tags

### Monitoring & Observability
- **Metrics naming:** Follow Prometheus naming conventions (`<namespace>_<name>_<unit>_total`)
- **Dashboards as code:** Grafana dashboards stored as JSON in version control
- **Alerting rules:** Every alert must have `summary`, `description`, `runbook_url`, and `severity` labels
- **SLO-driven alerts:** Alert on burn rate, not raw thresholds where possible

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
- Ask yourself: "Would a staff SRE approve this?"
- Run `terraform validate`, `terraform plan`, `kubectl dry-run`, check dashboards -- demonstrate correctness

### Self-Improvement
- After ANY correction from the user: record the pattern as a lesson
- Write rules for yourself that prevent the same mistake
- Review lessons at session start for relevant context

### Core Principles
- **Simplicity First**: Make every change as simple as possible. Minimal blast radius.
- **Root Cause Focus**: Find root causes. No temporary fixes or band-aids.
- **Minimal Footprint**: Only touch what's necessary. Avoid introducing misconfigurations.
- **Demand Elegance**: For non-trivial changes, pause and ask "is there a more elegant way?" Skip for simple fixes.
- **Subagent Strategy**: Use subagents liberally. One tack per subagent for focused execution.

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Plan & Apply | `/plan-and-apply` | Run `terraform init`, `validate`, `plan` for a target environment. Show the plan diff and optionally apply after confirmation. |
| Deploy Service | `/deploy-service` | Build Docker image, push to registry, and roll out to the target Kubernetes environment via Helm upgrade or Kustomize apply. |
| Incident Response | `/incident-response` | Pull current alerts from Prometheus/Alertmanager, check pod status and recent logs, and generate a triage summary with suggested next steps. |
