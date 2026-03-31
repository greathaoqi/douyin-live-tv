# Data Layer

This layer implements the protocols defined in Domain layer and handles concrete data operations: API networking, authentication, local storage.

**Responsibilities:**
- API client for Douyin API requests in `API/`
- Authentication handling and token storage in `Authentication/`
- Local persistence (SwiftData) in `Local/`
- Repository implementations in `Repositories/` that conform to Domain protocols

**Dependencies:**
- Depends on Domain layer (implements Domain protocols)
- Contains all third-party dependencies (Alamofire, KeychainSwift)
