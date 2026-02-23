# CLAUDE.md

## Project Overview

This is a SwiftUI iOS application built with Swift and targeting iOS 17+. The project follows the MVVM architecture pattern using Swift's `@Observable` macro, structured concurrency with `async/await`, and modern SwiftUI navigation with `NavigationStack`. Data persistence uses SwiftData, and networking is handled via `URLSession` with `Codable` models.

## Agent Team

### Routing Table

| Task Type | Agent | When to Use |
|-----------|-------|-------------|
| Feature planning, task breakdown, delegation | `tech-lead` | Any new feature request, complex task, or when the best approach is unclear |
| SwiftUI views, data models, networking, persistence | `ios-engineer` | Implementing features, writing business logic, integrating APIs, Core Data/SwiftData operations |
| UI layout, animations, design system, accessibility | `ui-designer` | Creating custom components, implementing animations, fixing layout issues, accessibility audits |
| Unit tests, UI tests, test plans, mocking | `test-engineer` | Writing XCTest/XCUITest cases, setting up test infrastructure, debugging test failures |
| Code review, PR review, quality checks | `code-reviewer` | All code changes before merge, architecture review, performance review |

### Orchestration Protocol

1. **Tech-lead is the routing authority.** When a complex task arrives, the tech-lead agent analyzes it, breaks it into subtasks, and delegates to the appropriate specialist(s). The tech-lead never writes production code directly.
2. **Main agent never implements directly** for multi-step tasks -- it delegates to specialists via the Task tool. Single-line fixes or configuration changes are the only exception.
3. **Handoff format:** When delegating, provide: (a) clear objective, (b) relevant file paths and SwiftUI view hierarchy context, (c) acceptance criteria with specific UI/behavior expectations, (d) which agent to hand off to next.
4. **Max 2 agents in parallel** for complex tasks to avoid merge conflicts in shared SwiftUI views or data models.
5. **Code reviewer is the quality gate** -- all code changes pass through code-reviewer before completion. No exceptions for "small" changes.

### Workflow Chains

- **New Feature**: tech-lead (break down) --> ios-engineer (implement models + views) --> ui-designer (polish UI + accessibility) --> test-engineer (write tests) --> code-reviewer (final review)
- **Bug Fix**: tech-lead (triage + root cause hypothesis) --> ios-engineer (fix) --> test-engineer (add regression test) --> code-reviewer (verify fix)
- **UI Polish**: tech-lead (scope) --> ui-designer (implement) --> code-reviewer (review)
- **Refactor**: tech-lead (plan) --> code-reviewer (review plan) --> ios-engineer (execute) --> test-engineer (verify no regressions) --> code-reviewer (final review)
- **Test Coverage**: tech-lead (identify gaps) --> test-engineer (write tests) --> code-reviewer (review test quality)

## Coding Standards

### Swift Naming Conventions
- Types and protocols: `UpperCamelCase` (e.g., `UserProfileView`, `NetworkServiceProtocol`)
- Functions, variables, properties: `lowerCamelCase` (e.g., `fetchUserData()`, `isLoading`)
- Constants: `lowerCamelCase` (not `SCREAMING_SNAKE_CASE`)
- Boolean properties: prefix with `is`, `has`, `should`, `can` (e.g., `isAuthenticated`, `hasUnsavedChanges`)
- Enum cases: `lowerCamelCase` (e.g., `.loading`, `.success(data)`)

### Architecture
- **MVVM with @Observable**: ViewModels use `@Observable` macro (not `ObservableObject`). Views observe with `@State` for owned state, `@Environment` for injected dependencies.
- **SwiftUI Navigation**: Use `NavigationStack` with `NavigationPath` for programmatic navigation. Avoid deprecated `NavigationView`.
- **Data Flow**: Parent owns state, children receive via bindings or environment. Minimize `@State` in child views.
- **Structured Concurrency**: Use `async/await` and `TaskGroup` for concurrent work. Annotate view models with `@MainActor`. Never use `DispatchQueue.main.async` in new code.

### File Organization
```
Sources/
  App/
    <AppName>App.swift
  Models/
    User.swift
  ViewModels/
    UserViewModel.swift
  Views/
    User/
      UserListView.swift
      UserDetailView.swift
    Components/
      LoadingView.swift
  Services/
    NetworkService.swift
    PersistenceService.swift
  Utilities/
    Extensions/
    Helpers/
```

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
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### Self-Improvement
- After ANY correction from the user: record the pattern as a lesson
- Write rules for yourself that prevent the same mistake
- Review lessons at session start for relevant context

### Core Principles
- **Simplicity First**: Make every change as simple as possible. Minimal code impact.
- **Root Cause Focus**: Find root causes. No temporary fixes.
- **Minimal Footprint**: Only touch what's necessary. Avoid introducing bugs.
- **Demand Elegance**: For non-trivial changes, pause and ask "is there a more elegant way?" Skip for simple fixes.
- **Subagent Strategy**: Use subagents liberally. One tack per subagent for focused execution.

## Available Skills

- `/build-and-test` -- Build the Xcode project and run the full test suite, reporting pass/fail results with error details.
- `/run-simulator` -- Build and launch the app in the iOS Simulator, automatically selecting an appropriate device.
