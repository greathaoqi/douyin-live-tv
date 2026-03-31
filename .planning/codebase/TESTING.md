# Testing Patterns

**Analysis Date:** 2026-03-31

## Test Framework

**Runner:**
- XCTest (built into Xcode)
- Config: Uses Xcode scheme and project configuration (no separate config file)

**Assertion Library:**
- Native XCTest assertions (`XCTAssertEqual`, `XCTAssertNotNil`, `XCTAssertTrue`, etc.)

**Run Commands:**
```bash
xcodebuild test -scheme DouyinLiveTV -destination 'platform=tvOS Simulator,name=Apple TV'
# Run all tests in Xcode via UI
open DouyinLiveTV.xcodeproj
```

## Test File Organization

**Location:**
- Separate test directory: `DouyinLiveTVTests/` at project root
- Not co-located with production code

**Naming:**
- Test files: `[ModuleName]Tests.swift` or `[Component]Tests.swift`
- Example: `APIClientTests.swift`, `LiveStatsServiceTests.swift`, `TokenStorageTests.swift`, `LiveRoomViewModelTests.swift`

**Structure:**
```
DouyinLiveTV/          # Production code
├── Domain/
├── Data/
├── UI/
└── App/
DouyinLiveTVTests/     # Test code
├── APIClientTests.swift
├── LiveStatsServiceTests.swift
└── ...
```

## Test Structure

**Suite Organization:**
```swift
import XCTest
@testable import DouyinLiveTV

final class APIClientTests: XCTestCase {

    func testGenerateQRCodeReturnsNonNilImageForValidInput() throws {
        // Given (arrange)
        let testUUID = "test-uuid"
        let size = CGSize(width: 300, height: 300)

        // When (act)
        let image = generateQRCode(from: testUUID, size: size)

        // Then (assert)
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.size.width, 300)
    }
}
```

**Patterns:**
- One `XCTestCase` subclass per component/module
- Setup: `override func setUpWithError() throws {}` for common setup when needed
- Teardown: `override func tearDownWithError() throws {}` for cleanup when needed
- Given-When-Then structure with comments in longer tests
- Clear function naming that describes what is tested: `test[FunctionName][Behavior]`

## Mocking

**Framework:**
- No mocking framework used; manual mocking or real lightweight objects

**Patterns:**
```swift
// No complex mocks needed - uses test data with stubbed responses
func testLiveStatsDecoding_success() throws {
    // Given: raw JSON as Data
    let json = """
    {
        "viewerCount": 1234,
        "isLive": true
    }
    """.data(using: .utf8)!
    
    // When: decode
    let stats = try decoder.decode(LiveStats.self, from: json)
    
    // Then: verify properties
    XCTAssertEqual(stats.viewerCount, 1234)
    XCTAssertEqual(stats.isLive, true)
}
```

**What to Mock:**
- Only external network requests need mocking; tests use local test data
- Most tests don't require mocking because they test pure logic/decoding

**What NOT to Mock:**
- `JSONDecoder`, `Data`, basic Foundation types are not mocked

## Fixtures and Factories

**Test Data:**
```swift
// Inline test fixtures directly in test methods
let responseWithTokens = QRStatusResponse(
    confirmed: true,
    accessToken: "test-access-token",
    refreshToken: "test-refresh-token",
    expiresAt: Date()
)

// JSON string fixtures for decoding tests
let json = """
{
  "viewerCount": 1234,
  "likeCount": 56789
}
""".data(using: .utf8)!
```

**Location:**
- Fixtures are defined inline in test methods
- No separate fixture files or factories for simple tests

## Coverage

**Requirements:** None enforced by default
- Xcode can show coverage within IDE
- No minimum coverage thresholds configured

**View Coverage:**
```bash
# In Xcode: Enable Code Coverage in test scheme settings
# Xcode → Product → Test → Show Coverage report
```

## Test Types

**Unit Tests:**
- Most tests are unit tests
- Scope: individual function, struct, or class
- Test decoding, endpoint configuration, business logic
- Located in `DouyinLiveTVTests/`

**Integration Tests:**
- Very few integration tests
- Some tests use actual `URLSession.shared` but no explicit integration suite

**E2E Tests:**
- No dedicated E2E UI tests; relies on manual testing for UI

## Common Patterns

**Async Testing:**
- XCTest supports async/await natively
```swift
func testSomethingAsync() async throws {
    let result = try await service.fetchStats(for: "123")
    XCTAssertEqual(result.id, "123")
}
```

**Error Testing:**
```swift
// Test for expected error
do {
    _ = try JSONDecoder().decode(MyType.self, from: badData)
    XCTFail("Expected decoding to throw an error")
} catch {
    // Expected error - test passes
}

// Or test that error type is correct
} catch let error as APIError where error == .invalidResponse {
    // Correct error type
}
```

---

*Testing analysis: 2026-03-31*
