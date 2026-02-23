# Swift & SwiftUI Coding Standards

These rules are enforced project-wide. All agents must follow them when writing or reviewing Swift code.

## Naming Conventions

- Types, protocols, and type aliases: `UpperCamelCase` -- `UserProfileView`, `NetworkServiceProtocol`, `JSONResponse`
- Functions, methods, properties, variables, constants: `lowerCamelCase` -- `fetchUserData()`, `isLoading`, `maxRetryCount`
- Boolean properties must use a verb prefix: `is`, `has`, `should`, `can`, `will` -- `isAuthenticated`, `hasUnsavedChanges`, `shouldRefresh`
- Enum cases: `lowerCamelCase` -- `.loading`, `.success(Data)`, `.networkError`
- Generic type parameters: single uppercase letter or descriptive `UpperCamelCase` -- `<T>`, `<Element>`, `<Content: View>`
- File names match the primary type they contain: `UserListView.swift`, `NetworkService.swift`

## Architecture: MVVM with @Observable

- Use `@Observable` macro for all view models. Do NOT use `ObservableObject` with `@Published` in new code.
- Annotate all view models with `@MainActor` to guarantee UI-safe updates.
- Views own their view model via `@State` when they are the source of truth, or receive it via initializer/environment.
- View models expose `private(set)` properties. Views read, view models mutate.
- One view model per screen or major feature area. Do not create god-object view models.
- Views must not contain business logic. If a view has an `if` statement based on data processing, move it to the view model.

```swift
// Correct
@Observable
@MainActor
final class ItemListViewModel {
    private(set) var items: [Item] = []
    private(set) var isLoading = false
}

// Incorrect -- do not use
class ItemListViewModel: ObservableObject {
    @Published var items: [Item] = []
}
```

## SwiftUI Patterns

- Use `NavigationStack` with value-based `NavigationLink`. Never use deprecated `NavigationView`.
- Use `.task {}` modifier for async work on view appearance. Do NOT use `onAppear` with `Task {}`.
- Use `#Preview` macro for all views. Include previews for multiple states (loading, empty, populated, error, dark mode).
- Use `ContentUnavailableView` for empty states.
- Use `Label("Title", systemImage: "icon.name")` instead of bare `Image(systemName:)` for accessibility.
- Prefer `.clipShape(RoundedRectangle(cornerRadius:))` over `.cornerRadius()` (deprecated).

## Structured Concurrency

- Use `async/await` for all asynchronous code. No completion handlers in new code.
- Use `TaskGroup` / `withThrowingTaskGroup` for parallel async operations.
- Never use `DispatchQueue.main.async` -- use `@MainActor` isolation instead.
- Never use `DispatchQueue.global().async` -- use `Task.detached` or a custom actor if truly needed.
- Store and cancel `Task` references when the owning scope is dismissed.
- Mark types that cross concurrency boundaries as `Sendable`.

## Error Handling

- Define domain-specific error enums conforming to `LocalizedError`.
- Provide `errorDescription` for all cases so users see meaningful messages.
- Never use empty `catch {}` blocks. Always handle or propagate errors.
- Use `Result` type only at API boundaries. Prefer `throws` internally.
- Every view that triggers async work must have a visible error state.

## Access Control

- Default to the most restrictive access level. Use `private` unless a wider scope is needed.
- Use `private(set)` for properties that should be readable but not externally writable.
- Mark types as `final` unless they are explicitly designed for subclassing.
- Use `fileprivate` sparingly -- prefer `private` with extensions in the same file.

## File Organization

- One primary type per file. Extensions of that type in the same file are fine.
- Order within a file: properties, initializers, public methods, private methods, nested types.
- Group related files into directories matching their architectural layer:
  - `Models/` -- data models and SwiftData entities
  - `ViewModels/` -- `@Observable` view models
  - `Views/` -- SwiftUI views, organized by feature subdirectories
  - `Views/Components/` -- reusable UI components
  - `Services/` -- networking, persistence, and other services
  - `Utilities/Extensions/` -- Swift extensions
  - `Utilities/Helpers/` -- utility functions and types

## Safety Rules

- No force unwraps (`!`) in production code. The only exception is static URLs: `URL(string: "https://example.com")!`.
- No `Any` or `AnyObject` when a protocol or generic will suffice.
- No implicitly unwrapped optionals (`var name: String!`) except for `@IBOutlet` (which we avoid in SwiftUI).
- No global mutable state. Use dependency injection via `@Environment` or initializer parameters.
- No `UserDefaults` for sensitive data. Use Keychain.
- No hardcoded API keys or secrets in source files.

## Testing Requirements

- Every new view model must have corresponding unit tests covering success and error paths.
- Every new service must have a protocol interface and a mock implementation for testing.
- UI tests are required for critical user flows (login, onboarding, primary feature).
- Test names describe the scenario: `testLoadUsers_WhenNetworkFails_SetsErrorState`.
- No `sleep()` in tests. Use `await`, expectations, or `waitForExistence(timeout:)`.
