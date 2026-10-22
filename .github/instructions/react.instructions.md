---
applyTo: "src/web/**/*.ts,src/web/**/*.tsx"
---

# React Development Instructions

## Technology

- React
- TypeScript
- Vite

## Components

Prefer:

- Functional components
- Small focused components
- Reusable components
- Clear component responsibilities

Avoid unnecessarily large components.

## TypeScript

Prefer strong typing.

Avoid `any` unless there is a documented reason.

Prefer explicit interfaces/types for API contracts.

## State

Keep state as close as possible to where it is required.

Avoid unnecessary global state.

Do not duplicate server state unnecessarily.

## API Communication

Keep HTTP communication outside presentation components.

Prefer dedicated API clients/services.

Do not scatter fetch/HTTP calls throughout UI components.

## UI States

Handle:

- Loading
- Error
- Empty
- Success

Do not assume API calls always succeed.

## Error Handling

Display user-friendly error messages.

Do not expose internal API/server errors directly to users.

## Performance

Avoid unnecessary re-renders.

Use memoization only when it provides a meaningful benefit.

Do not optimize prematurely.

## Accessibility

Use semantic HTML.

Ensure interactive elements are accessible.

Do not rely only on visual indicators.

## Security

Never hardcode:

- API keys
- tokens
- passwords
- secrets

Do not expose sensitive information in frontend code.

## Code Quality

Prefer:

- readable code
- simple components
- reusable hooks where appropriate
- clear naming
- existing project conventions

Avoid unnecessary libraries and abstractions.