# App Layer

This layer contains the app entry point, configuration, and dependency injection container.

**Responsibilities:**
- App entry point (`DouyinLiveTVApp.swift`)
- Application-level configuration
- Manual dependency container that wires up all dependencies
- Environment setup

**Dependencies:**
- Depends on all other layers (only for composition)
- Does not contain business logic
