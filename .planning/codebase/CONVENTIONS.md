# Coding Conventions

**Analysis Date:** 2026-03-31

## Naming Patterns

**Files:**
- PascalCase for Swift files matching the type/struct/class name they contain
- Example: `LiveStatsService.swift`, `APIClient.swift`, `AddRoomView.swift`, `LiveRoom.swift`

**Functions:**
- camelCase for function names
- Example: `fetchStats(for:)`, `generateQRCode(from:size:)`, `checkStoredCredentials()`
- Func parameters use external and internal naming: `func fetchStats(for roomId: String)`

**Variables:**
- camelCase for property and variable names
- Example: `roomId`, `title`, `isLive`, `apiClient`, `initialRoomId`
- Constants use lower camelCase (upper camelCase for types only)

**Types:**
- PascalCase for structs, classes, enums, and protocols
- Example: `APIError`, `APIClient`, `LiveRoom`, `LiveStats`, `Endpoint`
- Generic type parameters are capitalized: `Response: Decodable`

## Code Style

**Formatting:**
- 4-space indentation (standard Xcode default)
- Open braces on same line as declaration: `class DependencyContainer {`
- Trailing newline at end of files
- Clear spacing between functions with one blank line

**Linting:**
- No external linter configured (relies on Xcode default)
- No SwiftLint config detected

## Import Organization

**Order:**
1. Foundation/System frameworks
2. Third-party modules (SwiftUI, SwiftData, UIKit)
3. Module imports (e.g., `import DouyinLiveTVDomain`)
4. No explicit grouping, but imports are sorted by system/framework order

**Path Aliases:**
- Not applicable (Swift, no path aliases needed)

## Error Handling

**Patterns:**
- Use Swift's built-in `Error` protocol for custom error types
- Throwing functions with `throws` keyword
- Async/await pattern for asynchronous code
- Do-catch for error handling at point of use
- Associated values capture context: `case networkError(Error)`

```swift
public enum APIError: Error, Equatable {
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case unauthorized
}
```

- Errors conform to `Equatable` when possible for testing
- `CustomStringConvertible` conformance for human-readable error descriptions

## Logging

**Framework:** `print` statements used infrequently; no dedicated logging framework in evidence

**Patterns:**
- No consistent logging pattern observed
- Most errors are thrown to caller rather than logged internally

## Comments

**When to Comment:**
- Header comments at top of files explain purpose
- `// MARK: -` used for section grouping in test files
- Comments explain "why" not "what" when non-obvious
- Example: top file comment explains requirements met: `Implements session persistence requirement (AUTH-03).`

**JSDoc/TSDoc:**
- Not applicable (Swift documentation uses /// comments)
- No consistent documentation comment pattern observed; code is self-documenting in most cases

## Function Design

**Size:**
- Functions are kept small and single-purpose
- Most functions are under 20 lines
- Initializers configure dependencies clearly with multiple lines, but this is expected

**Parameters:**
- Clear parameter naming with external argument labels
- Default parameters used for optional values: `avatarUrl: String? = nil`
- Keep parameter counts reasonable (most have 1-4 parameters)

**Return Values:**
- Explicit return types
- For async code, return the result rather than using completion handlers
- Optional returns where appropriate (e.g., `generateQRCode` returns `UIImage?`)

## Module Design

**Exports:**
- `public` access control for API that needs to be accessible across modules
- `private` for internal implementation details
- `fileprivate` not used extensively
- `internal` default when no modifier needed

**Barrel Files:**
- Not used; each type in its own file

---

*Convention analysis: 2026-03-31*
