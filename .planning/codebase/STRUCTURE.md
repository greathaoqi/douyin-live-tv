# Codebase Structure

**Analysis Date:** 2026-03-31

## Directory Layout

```
project-root/
├── DouyinLiveTV/               # Main iOS/tvOS application
│   ├── App/                    # App entry point and DI container
│   ├── Assets.xcassets/        # Asset catalog for images and icons
│   ├── Data/                   # Data layer implementation
│   │   ├── Keychain/           # Keychain token storage
│   │   ├── Network/            # API client and endpoints
│   │   ├── Services/           # Concrete service implementations
│   │   └── Repositories/       # Repository implementations
│   ├── Domain/                 # Domain layer (pure Swift business logic)
│   │   ├── Common/             # Shared common types
│   │   ├── Models/             # Core business models
│   │   ├── Services/           # Domain service protocols/implementations
│   │   └── UseCases/           # Use case definitions
│   ├── UI/                     # UI layer (SwiftUI views by feature)
│   │   ├── AddRoom/            # Add room screen
│   │   ├── Common/             # Shared UI components
│   │   ├── Favorites/          # Favorites list and management
│   │   ├── LiveRoom/           # Live room related UI
│   │   ├── Login/              # Login/QR code screen
│   │   ├── Main/               # Main tab navigation
│   │   ├── RoomList/           # Room list components
│   │   └── WatchLive/          # Live playback screen
│   ├── Preview Content/        # Xcode preview assets
│   └── Info.plist              # App configuration
├── DouyinLiveTV.xcodeproj/     # Xcode project file
├── DouyinLiveTVTests/          # Unit test target
├── DouyinLiveTVTopShelf/       # Top Shelf extension for tvOS
└── .planning/                  # Project planning and documentation
```

## Directory Purposes

**App:**
- Purpose: Application-level configuration and bootstrapping
- Contains: App entry point, dependency injection container, global state managers
- Key files:
  - `DouyinLiveTV/App/DouyinLiveTVApp.swift` - Main app entry point
  - `DouyinLiveTV/App/DependencyContainer.swift` - Manual DI container
  - `DouyinLiveTV/App/AuthStateManager.swift` - Global authentication state

**Domain:**
- Purpose: Core business logic and models with no external dependencies
- Contains: Models, domain services, common types, repository protocols
- Key files:
  - `DouyinLiveTV/Domain/Models/LiveRoom.swift` - SwiftData persisted favorite room
  - `DouyinLiveTV/Domain/Models/LiveStats.swift` - Live room statistics from API
  - `DouyinLiveTV/Domain/Services/PlayerService.swift` - AVPlayer lifecycle management

**Data:**
- Purpose: Implements data access and conforms to Domain protocols
- Contains: API client, keychain storage, authentication, persistence, services
- Key files:
  - `DouyinLiveTV/Data/Network/APIClient.swift` - Generic API client
  - `DouyinLiveTV/Data/Network/DouyinAPIEndpoints.swift` - Douyin API endpoint definitions
  - `DouyinLiveTV/Data/Services/FavoritesService.swift` - Favorites management with SwiftData
  - `DouyinLiveTV/Data/Keychain/TokenStorage.swift` - Secure token storage in Keychain

**UI:**
- Purpose: Feature-based user interface organization for tvOS
- Contains: SwiftUI views and view models organized by screen/feature
- Key files:
  - `DouyinLiveTV/UI/Common/ContentView.swift` - Root view navigation between login/main
  - `DouyinLiveTV/UI/Login/LoginView.swift` - QR code login screen
  - `DouyinLiveTV/UI/Favorites/FavoritesView.swift` - Favorites list screen
  - `DouyinLiveTV/UI/WatchLive/WatchLiveView.swift` - Live playback screen

## Key File Locations

**Entry Points:**
- `DouyinLiveTV/App/DouyinLiveTVApp.swift`: App main entry point

**Configuration:**
- `DouyinLiveTV/Info.plist`: Application info and permissions
- `DouyinLiveTV.xcodeproj/project.pbxproj`: Xcode project configuration

**Core Logic:**
- `DouyinLiveTV/Domain/`: Business models and rules
- `DouyinLiveTV/Data/`: Network and persistence implementation
- `DouyinLiveTV/UI/`: User interface and interaction

**Testing:**
- `DouyinLiveTVTests/`: Unit tests for application logic

**Extension:**
- `DouyinLiveTVTopShelf/`: tvOS Top Shelf extension for quick access to favorites

## Naming Conventions

**Files:**
- PascalCase for Swift files: `AuthStateManager.swift`, `FavoritesService.swift`, `LiveRoom.swift`
- One type per file: File name matches the main type contained within
- Group files by feature/screen in UI layer

**Directories:**
- PascalCase for layer directories: `App`, `Domain`, `Data`, `UI`
- PascalCase for subdirectories: `Models`, `Services`, `Network`, `Keychain`
- Features in UI directory use PascalCase: `Login`, `Favorites`, `WatchLive`

**Types:**
- Structs for value types: `LiveStats`, `Endpoint`, `LiveRoom`
- Classes for reference-types with identity: `FavoritesService`, `APIClient`, `AuthStateManager`
- Enums for errors and states: `APIError`, `AuthStateManager.State`

**Variables & Functions:**
- camelCase for function names: `addRoom(roomId:)`, `fetchStats(for:)`
- camelCase for instance properties: `favorites`, `isLive`, `roomId`
- PascalCase for static and type names: `APIError`, `LiveStats`

## Where to Add New Code

**New Feature:**
- Primary domain logic: `DouyinLiveTV/Domain/` (add model/service)
- Data implementation: `DouyinLiveTV/Data/` (add service/repository)
- UI: `DouyinLiveTV/UI/FeatureName/` (add view and view model)
- Register dependencies: `DouyinLiveTV/App/DependencyContainer.swift`
- Tests: `DouyinLiveTVTests/`

**New Component/Module:**
- Implementation: `DouyinLiveTV/Domain/Component/` if pure business logic, otherwise `DouyinLiveTV/Data/Component/`

**Utilities:**
- Shared helpers: `DouyinLiveTV/Domain/Common/` if shared across domain, `DouyinLiveTV/Data/Common/` or `DouyinLiveTV/UI/Common/` for layer-specific

**New API Endpoint:**
- Add endpoint definition in `DouyinLiveTV/Data/Network/DouyinAPIEndpoints.swift`
- Model response in `DouyinLiveTV/Domain/Models/` if new model

## Special Directories

**.planning/:**
- Purpose: Project planning, architecture docs, phase breakdowns, research
- Generated: Yes (by GSD process)
- Committed: Yes

**DouyinLiveTVTopShelf/:**
- Purpose: tvOS Top Shelf extension that provides quick access to favorite rooms on the TV home screen
- Generated: No (hand-written)
- Committed: Yes

**DouyinLiveTVTests/:**
- Purpose: Unit tests for core application logic
- Generated: No (hand-written and Xcode generated)
- Committed: Yes

---

*Structure analysis: 2026-03-31*
