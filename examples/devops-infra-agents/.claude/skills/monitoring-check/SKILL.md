---
name: monitoring-check
description: "Review service health, alerts, and recent operational signals using the monitoring tools configured in this repository."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Grep
argument-hint: "[service]"
---

Check the health of `$ARGUMENTS` using this repository's documented observability setup.

## Steps

1. Find the service's health endpoint, dashboards, alerts, and runbooks in the repo.
2. Check recent health and alert status using available read-only commands.
3. Compare symptoms with recent deployment or configuration changes when that data is available.
4. Report the service, time range, checks run, findings, and relevant runbook steps.

Do not change alert settings, silence alerts, or restart services. If monitoring access is missing, say what is needed.
