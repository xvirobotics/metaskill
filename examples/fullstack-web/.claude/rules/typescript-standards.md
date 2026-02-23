# TypeScript and React Coding Standards

These standards apply to all TypeScript code in both the client (React) and server (Node.js/Express) packages.

## TypeScript Configuration

- `strict: true` must be enabled in all tsconfig.json files
- `noUncheckedIndexedAccess: true` to catch undefined array/object access
- `exactOptionalPropertyTypes: true` to distinguish between missing and explicitly undefined properties
- Target ES2022 or later for modern JavaScript features

## Type Safety

- Never use `any`. Use `unknown` when the type is genuinely unknown, then narrow with type guards or Zod parsing.
- Prefer `interface` for object shapes that may be extended. Use `type` for unions, intersections, and mapped types.
- Use `as const` assertions for literal objects and arrays that should not be widened.
- Annotate return types explicitly on exported functions, service methods, and API handlers. Let TypeScript infer return types for private/local functions.
- Use discriminated unions with exhaustive `switch` statements. Add a `default: never` case to catch unhandled variants at compile time.
- Avoid type assertions (`as Type`) except when interacting with untyped libraries. Prefer type guards instead.

## Naming Conventions

- **Variables and functions**: camelCase (`getUserById`, `isAuthenticated`, `formatDate`)
- **Types and interfaces**: PascalCase (`UserProfile`, `CreatePostRequest`, `AuthState`)
- **Constants**: UPPER_SNAKE_CASE for true constants (`MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE`), camelCase for constant references (`queryKeys`, `routePaths`)
- **Enum members**: PascalCase (`UserRole.Admin`, `OrderStatus.Pending`)
- **File names**: PascalCase for React components (`UserCard.tsx`, `LoginPage.tsx`), camelCase for everything else (`userService.ts`, `authMiddleware.ts`, `queryKeys.ts`)
- **Boolean variables**: prefix with `is`, `has`, `can`, `should` (`isLoading`, `hasPermission`, `canEdit`)

## React Component Standards

- Functional components only. No class components under any circumstances.
- Use named exports exclusively. No default exports.
- Define prop interfaces directly above the component, named `[ComponentName]Props`:
  ```typescript
  interface UserCardProps {
    user: User;
    onSelect: (userId: string) => void;
  }

  export function UserCard({ user, onSelect }: UserCardProps) { ... }
  ```
- Destructure props in the function signature, not in the body.
- Extract complex logic into custom hooks. A component should primarily compose hooks and render JSX.
- Use `React.lazy` and `Suspense` for route-level code splitting.
- Wrap route-level components with Error Boundaries.

## Hooks Rules

- Custom hooks must be prefixed with `use` and placed in the `hooks/` directory.
- Always provide complete dependency arrays for `useEffect`, `useMemo`, and `useCallback`. Lint rules enforce this.
- Prefer `useMemo` and `useCallback` only when profiling proves a performance benefit. Do not wrap every function or value preemptively.
- Avoid `useEffect` for data fetching. Use TanStack Query hooks instead.
- Clean up side effects in `useEffect` return functions (event listeners, timers, subscriptions).

## Import Organization

Order imports in this sequence, separated by blank lines:
1. React and React-related packages (`react`, `react-dom`, `react-router-dom`)
2. Third-party libraries (`@tanstack/react-query`, `zod`, `clsx`)
3. Internal aliases/absolute imports (`@/components`, `@/hooks`, `@/lib`)
4. Relative imports (`./UserAvatar`, `../types`)
5. Type-only imports (`import type { User } from ...`)

## Error Handling

- Use typed error classes on the backend. Never throw plain strings or generic Error objects for expected failures.
- On the frontend, handle all three states for async operations: loading, error, and success. Never leave error states unhandled.
- Use Error Boundaries to catch rendering errors and display fallback UI.
- Log errors with structured context (user ID, request ID, operation name), never just the error message.

## Async Patterns

- Use `async/await` exclusively. No `.then()/.catch()` chains.
- Wrap async Express handlers in error-catching middleware to avoid unhandled promise rejections.
- Use `Promise.all` for independent parallel operations, `Promise.allSettled` when partial failure is acceptable.
- Set timeouts on external API calls and database queries to prevent hanging requests.

## Testing

- Test files live next to the source file they test: `UserCard.tsx` and `UserCard.test.tsx` in the same directory.
- Name test files with `.test.ts` or `.test.tsx` suffix.
- Use descriptive test names that state the expected behavior: `it('returns 401 when the JWT token is expired')`.
- Follow the Arrange-Act-Assert pattern in every test.
- Mock external dependencies at the boundary (HTTP calls, database), not internal modules.

## Code Organization

- One component per file. One service per file. One route group per file.
- Keep files under 300 lines. If a file exceeds this, decompose it.
- Group related files by feature or domain, not by type (prefer `features/users/` over `components/`, `services/`, `routes/` when the project grows large enough).
- Shared types between client and server go in the `shared/types/` package.
