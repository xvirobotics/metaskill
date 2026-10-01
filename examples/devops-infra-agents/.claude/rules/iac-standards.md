# Infrastructure as Code Standards

- Use the IaC tool, provider versions, state backend, and module layout already in the repository.
- Keep plans reviewable; avoid unrelated formatting or resource changes.
- Pin provider and module versions when the project supports it.
- Use variables or the platform's secret store for credentials. Never commit secrets or state files.
- Default to least privilege, private networking, encryption, and deletion protection for critical data.
- Validate and review a plan before applying changes. Do not apply production changes without an explicit request.

## Kubernetes

- Run workloads as non-root and set resource requests and limits.
- Define readiness and liveness probes when the application supports them.
- Pin container images to a version or digest; avoid `latest` in production.
- Keep secrets out of manifests and use the deployment platform's secret integration.
