---
name: deploy-preview
description: "Build Docker images and launch a local preview environment with docker-compose. Use to test the full stack locally before merging."
user-invocable: true
disable-model-invocation: true
context: fork
allowed-tools: Bash, Read, Grep
---

You are a deployment preview agent. Your job is to build and launch a local preview environment using Docker, then verify it is healthy.

## Current State

Current branch: !`git branch --show-current`
Git status: !`git status --short`

## Deployment Steps

### Step 1: Verify Docker is Available

```bash
docker --version && docker compose version
```

If Docker is not available, report that Docker must be installed and stop.

### Step 2: Stop Any Existing Preview

```bash
docker compose -f docker-compose.yml down --remove-orphans 2>/dev/null || true
```

### Step 3: Build Docker Images

Build the application image using the multi-stage Dockerfile:

```bash
docker compose -f docker-compose.yml build --no-cache
```

If the build fails, report the full error output. Common issues: missing files in build context (check `.dockerignore`), npm install failures, TypeScript compilation errors.

### Step 4: Start Services

```bash
docker compose -f docker-compose.yml up -d
```

Wait for services to be healthy:

```bash
echo "Waiting for services to start..."
sleep 5
docker compose -f docker-compose.yml ps
```

### Step 5: Run Database Migrations

```bash
docker compose -f docker-compose.yml exec -T app npx prisma migrate deploy
```

If migrations fail, report the error. Common issues: database not ready yet (may need longer wait), migration conflicts.

### Step 6: Health Check

Verify the application is responding:

```bash
curl -sf http://localhost:3000/api/health || echo "HEALTH CHECK FAILED"
```

If the health check fails, inspect the logs:

```bash
docker compose -f docker-compose.yml logs --tail=50 app
```

### Step 7: Report

```
## Preview Deployment Results

**Branch:** [branch name]
**Status:** RUNNING / FAILED at [step]

### Services
| Service | Status | Port |
|---------|--------|------|
| app | running/stopped | 3000 |
| db | running/stopped | 5432 |
| client | running/stopped | 5173 |

### Access URLs
- API: http://localhost:3000/api
- Frontend: http://localhost:5173
- Health: http://localhost:3000/api/health

### Cleanup
To stop the preview environment:
docker compose -f docker-compose.yml down
```
