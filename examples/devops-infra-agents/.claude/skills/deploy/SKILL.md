---
name: deploy
description: "Validate and prepare a service deployment using the tools and environments configured in this repository."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Grep
argument-hint: "[environment]"
---

Prepare a deployment for `$ARGUMENTS`. Do not deploy to a live environment unless the user explicitly asks.

## Steps

1. Inspect the deployment workflow, target environment, and required checks.
2. Confirm the working tree and identify the files that will be deployed.
3. Run the repository's configured format, validation, and test commands.
4. Validate the Kubernetes manifests or Helm chart with the installed project tooling.
5. If available, produce and review a deployment plan. Do not apply it.
6. Report the checks run, plan summary, and any manual steps needed to deploy or roll back.

Stop if a required tool, environment, or check is missing. Do not invent commands or bypass failing checks.
