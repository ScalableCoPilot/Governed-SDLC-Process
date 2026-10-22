# AICustomerManagement - GitHub Copilot Instructions

## 1. Project Overview

AICustomerManagement is a full-stack application with:

- Frontend: React + TypeScript
- Backend: ASP.NET Core Web API
- Framework: .NET 10
- Database: SQL Server
- ORM: Entity Framework Core
- Source Control: Git + GitHub

The repository contains frontend, backend, tests and documentation
within a single repository.

---

## 2. Repository Structure

The repository follows this structure:

- src/api/AICustomerManagement.Api
- src/api/AICustomerManagement.Application
- src/api/AICustomerManagement.Domain
- src/api/AICustomerManagement.Infrastructure
- src/web/AICustomerManagement.Web
- tests
- docs
- .github

Keep frontend and backend concerns separated.

---

## 3. Backend Architecture

The backend follows a layered architecture.

Dependency direction:

API
  ↓
Application
  ↓
Domain

Infrastructure
  ↓
Application
  ↓
Domain

Domain must not depend on Application,
Infrastructure or API.

Application must not depend on Infrastructure or API.

Infrastructure contains technical implementations
such as database access and external integrations.

API contains HTTP/API concerns only.

---

## 4. Domain Layer Rules

The Domain layer contains:

- Entities
- Value Objects
- Domain rules
- Domain-specific abstractions

The Domain layer must remain independent of
framework-specific infrastructure concerns.

Do not add database-specific implementation
to the Domain layer.

---

## 5. Application Layer Rules

The Application layer contains:

- Use cases
- Application services
- DTOs
- Application interfaces
- Validation related to application use cases

Business/application logic should not be placed
inside API controllers.

Application should depend only on Domain
and its own abstractions.

---

## 6. Infrastructure Layer Rules

Infrastructure contains:

- Entity Framework Core
- DbContext
- Repository implementations
- Database configuration
- External service implementations

Infrastructure may depend on Application and Domain.

Do not move business rules into Infrastructure
just because they involve database operations.

---

## 7. API Layer Rules

Controllers must remain thin.

Controllers should primarily:

- Receive HTTP requests
- Validate/request-bind input
- Call Application services/use cases
- Return appropriate HTTP responses

Do not place business logic inside controllers.

Do not expose EF Core entities directly
as API response contracts.

Prefer DTOs for API requests and responses.

---

## 8. React Rules

The frontend uses:

- React
- TypeScript
- Vite

Prefer:

- Functional components
- TypeScript types/interfaces
- Reusable components
- Custom hooks where appropriate
- Clear separation between UI and application logic

Components should remain focused and reasonably small.

Handle:

- Loading states
- Error states
- Empty states
- Success states

Avoid unnecessary state and unnecessary re-renders.

---

## 9. API Communication

React should communicate with the backend
through defined API clients/services.

Do not place HTTP calls randomly inside
multiple UI components.

Keep API communication separate from presentation logic.

---

## 10. Error Handling

Backend APIs should return consistent error responses.

Do not expose internal exceptions,
stack traces or sensitive information to clients.

Use appropriate HTTP status codes.

Handle expected business/application errors explicitly.

---

## 11. Async Programming

Use async/await for I/O operations.

Avoid blocking calls such as:

- .Result
- .Wait()

Do not introduce unnecessary asynchronous
wrappers around synchronous operations.

---

## 12. Database and EF Core

Use Entity Framework Core for database access.

Be conscious of:

- N+1 queries
- Unnecessary tracking
- Large result sets
- Inefficient joins
- Missing pagination
- Unnecessary database round trips

Do not load large datasets into memory unnecessarily.

For read-only queries, consider AsNoTracking()
when appropriate.

---

## 13. Security

Never hardcode:

- Passwords
- API keys
- Connection strings
- Access tokens
- Client secrets

Never commit secrets to Git.

Do not log sensitive information.

Validate external input.

---

## 14. Testing

Business logic should have unit tests.

API behaviour should have integration tests
where appropriate.

Tests should verify behaviour rather than
implementation details.

Do not modify tests merely to make
incorrect production code pass.

---

## 15. Code Quality

Prefer:

- Simple solutions
- Readable code
- Explicit naming
- Small focused methods
- Single responsibility
- Existing project patterns

Avoid unnecessary abstractions.

Do not introduce design patterns
unless they solve an actual problem.

Do not introduce a new NuGet or npm package
without explaining the reason.

---

## 16. Change Scope

Do not modify unrelated files.

Keep changes focused on the requested requirement.

Before making a significant architectural change,
first analyze the existing implementation.

---

## 17. Git Awareness

Prefer small, logically grouped changes.

Do not modify Git configuration,
branches or remote repositories unless explicitly requested.

Do not generate commits automatically
unless explicitly requested.

---

## 18. Copilot Behaviour

When a request involves a significant change:

1. Understand the existing implementation.
2. Identify the affected layers/files.
3. Explain the proposed approach when appropriate.
4. Implement only the required changes.
5. Run or recommend relevant tests.
6. Review the implementation for correctness,
   security and maintainability.

Do not guess missing business requirements.

If a requirement is ambiguous and the ambiguity
could change the implementation, ask for clarification.

Do not invent database fields,
API contracts or external APIs.

Prefer existing project conventions over introducing
new patterns.

---

## 19. AI Safety Rule

Generated code must be treated as a proposal,
not automatically trusted production code.

Always consider:

- Correctness
- Security
- Performance
- Maintainability
- Test coverage
- Business correctness

The developer remains responsible for
the final implementation and architectural decisions.