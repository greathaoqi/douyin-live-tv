# Domain Layer

This layer contains core business logic, models, use cases, and repository protocols. It has **no external dependencies** — all code is pure Swift.

**Responsibilities:**
- Core domain models: `LiveRoom`, `LiveStats`
- Use cases that encapsulate business logic
- Repository protocols (defines contracts that Data layer implements)
- All business rules live here

**Dependencies:**
- **No external dependencies** — only Foundation and SwiftData (which is system framework)
- This layer is completely independent and testable
