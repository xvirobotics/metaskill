---
name: api-test
description: "Run API integration tests against the running backend, verify endpoints return expected responses and status codes. Use after deploying a preview or starting the dev server."
user-invocable: true
context: fork
allowed-tools: Bash, Read, Grep
---

You are an API integration test agent. Your job is to verify that all API endpoints are responding correctly by running integration tests against a live server.

## Current State

Current branch: !`git branch --show-current`
Recent changes: !`git diff --name-only HEAD~3 2>/dev/null || echo "fewer than 3 commits"`

## Test Procedure

### Step 1: Verify Server is Running

```bash
curl -sf http://localhost:3000/api/health && echo "Server is healthy" || echo "Server is not responding"
```

If the server is not running, report that the server must be started first (with `npm run dev` or `/deploy-preview`) and stop.

### Step 2: Run Integration Tests

Run the API integration test suite:

```bash
DATABASE_URL="${DATABASE_URL_TEST:-postgresql://test:test@localhost:5432/myapp_test}" npx vitest run --config vitest.integration.config.ts 2>/dev/null || npx vitest run tests/integration/ 2>/dev/null || npx vitest run --grep "integration|api|endpoint"
```

If a dedicated integration test config or directory exists, use it. Otherwise, run tests that match integration/API patterns.

### Step 3: Manual Endpoint Verification

If integration tests are not set up yet, manually verify key endpoints:

**Health Check:**
```bash
curl -s -w "\nHTTP_STATUS:%{http_code}" http://localhost:3000/api/health
```

**Auth Endpoints (if they exist):**
```bash
# Register
curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPass123!","name":"Test User"}'

# Login
curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPass123!"}'
```

**List Endpoints (verify pagination):**
```bash
curl -s -w "\nHTTP_STATUS:%{http_code}" http://localhost:3000/api/users?page=1&limit=10
```

**Validation Testing (send invalid data):**
```bash
curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"not-an-email"}'
```

Expected: 400 status with validation error envelope.

**404 Handling:**
```bash
curl -s -w "\nHTTP_STATUS:%{http_code}" http://localhost:3000/api/nonexistent
```

Expected: 404 status with error envelope.

### Step 4: Check Response Format Consistency

For each response, verify:
- Success responses use `{ "data": ... }` envelope
- Error responses use `{ "error": { "code": "...", "message": "..." } }` envelope
- List responses include pagination meta: `{ "data": [...], "meta": { "total": N, "page": N, "limit": N } }`
- Content-Type header is `application/json`

## Report Format

```
## API Test Results

**Server:** http://localhost:3000
**Status:** PASS / FAIL

### Endpoint Results
| Method | Endpoint | Expected | Actual | Status |
|--------|----------|----------|--------|--------|
| GET | /api/health | 200 | [code] | pass/fail |
| POST | /api/auth/register | 201 | [code] | pass/fail |
| POST | /api/auth/login | 200 | [code] | pass/fail |
| GET | /api/users | 200 | [code] | pass/fail |
| POST | /api/auth/register (invalid) | 400 | [code] | pass/fail |
| GET | /api/nonexistent | 404 | [code] | pass/fail |

### Response Format Checks
- JSON envelope consistency: pass/fail
- Error format consistency: pass/fail
- Pagination meta present on list endpoints: pass/fail

### Issues Found
[List any failures with details]

### Summary
[Tested N endpoints, M passed, K failed]
```
