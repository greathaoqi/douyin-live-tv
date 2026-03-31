# UI Layer

This layer contains all Views, ViewModels, and UI components organized by screen.

**Responsibilities:**
- SwiftUI Views for each screen
- ViewModels that manage UI state using MVVM pattern
- Shared UI components in `Common/`
- One directory per screen: `RoomList/`, `LiveRoom/`, `AddRoom/`

**Dependencies:**
- Only depends on Domain layer (models and protocols)
- **Never directly imports or uses Alamofire, Data layer components, or third-party networking**
- Follows tvOS Human Interface Guidelines with focus-based navigation
