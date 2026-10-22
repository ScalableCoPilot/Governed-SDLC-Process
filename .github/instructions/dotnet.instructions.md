---
applyTo: "src/api/**/*.cs"
---

# .NET Development Instructions

## Technology

- Use .NET 10.
- Use ASP.NET Core Web API.
- Use C#.
- Follow the existing project architecture.

## Architecture

Backend layers:

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

Domain must remain independent.

Application must not depend on Infrastructure or API.

Infrastructure contains technical implementations.

API contains HTTP concerns.

## API

Controllers/endpoints should remain thin.

They should:

- Receive requests
- Validate/bind input
- Call Application services/use cases
- Return HTTP responses

Do not place business logic inside controllers.

## Application

Application contains:

- Use cases
- Application services
- DTOs
- Application interfaces
- Application-level validation

Keep business workflows here.

## Domain

Domain contains:

- Entities
- Value Objects
- Domain rules
- Domain abstractions

Do not add EF Core or infrastructure-specific code to Domain.

## Infrastructure

Infrastructure contains:

- EF Core
- DbContext
- Repository implementations
- Database configuration
- External service implementations

Keep technical implementation details here.

## C# Coding

Prefer:

- Async/await for I/O
- Dependency injection
- Clear naming
- Small focused methods
- Nullable reference types
- Guard clauses where appropriate

Avoid:

- .Result
- .Wait()
- unnecessary abstractions
- unnecessary packages

## API Contracts

Use DTOs for API requests and responses.

Do not expose EF Core entities directly.

## Error Handling

Use consistent API error responses.

Do not expose internal exceptions or stack traces.

Use appropriate HTTP status codes.

## Database

Be aware of:

- N+1 queries
- unnecessary tracking
- unnecessary database round trips
- large result sets
- missing pagination
- inefficient queries

Do not load large datasets unnecessarily.

## Security

Never hardcode:

- passwords
- API keys
- tokens
- secrets
- connection strings

Never log sensitive information.

## Testing

Business rules require unit tests.

API behaviour should have integration tests where appropriate.

Tests should verify behaviour, not implementation details.