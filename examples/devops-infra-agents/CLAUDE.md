# DevOps Infrastructure Team

This example covers Terraform or Pulumi infrastructure, Docker and Kubernetes deployments, CI/CD, and service observability.

## Agent Team

| Task | Agent |
| --- | --- |
| Plan changes that cross infrastructure, deployment, or monitoring | `tech-lead` |
| Terraform or Pulumi, cloud resources, and infrastructure tests | `infra-engineer` |
| Docker, Kubernetes, CI/CD, and release workflows | `platform-engineer` |
| Review security, reliability, and operational changes | `code-reviewer` |

## Workflow

1. The tech lead scopes the change and routes it to the right specialist.
2. Specialists inspect existing conventions before editing files.
3. Run the relevant validation and deployment or monitoring skill.
4. Ask the code reviewer to check the diff before merging.

Keep changes small, use the repository's existing tools, and never apply infrastructure changes without an explicit request.
