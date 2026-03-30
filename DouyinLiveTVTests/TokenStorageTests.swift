//
//  TokenStorageTests.swift
//  DouyinLiveTVTests
//
//  Unit tests for TokenStorage Keychain storage
//

import XCTest
import KeychainSwift
@testable import DouyinLiveTV

class TokenStorageTests: XCTestCase {
    var keychain: KeychainSwift!
    var tokenStorage: TokenStorage!

    override func setUpWithError() throws {
        try super.setUpWithError()
        keychain = KeychainSwift()
        tokenStorage = TokenStorage(keychain: keychain)
        // Clear any existing tokens before each test
        tokenStorage.clear()
    }

    override func tearDownWithError() throws {
        tokenStorage.clear()
        tokenStorage = nil
        keychain = nil
        try super.tearDownWithError()
    }

    func testLoadReturnsNilWhenNoTokensSaved() {
        // When no tokens are saved
        let token = tokenStorage.load()
        // Then load returns nil
        XCTAssertNil(token)
    }

    func testHasValidTokensReturnsFalseWhenNoTokens() {
        // When no tokens are saved
        let hasValid = tokenStorage.hasValidTokens()
        // Then hasValidTokens returns false
        XCTAssertFalse(hasValid)
    }

    func testSaveAndLoadTokenSuccess() throws {
        // Given a test token
        let futureDate = Date().addingTimeInterval(3600)
        let testToken = AuthToken(
            accessToken: "test-access-token-123",
            refreshToken: "test-refresh-token-456",
            expiresAt: futureDate
        )

        // When saving and loading back
        try tokenStorage.save(testToken)
        let loadedToken = tokenStorage.load()

        // Then loaded token matches original
        XCTAssertNotNil(loadedToken)
        XCTAssertEqual(loadedToken?.accessToken, testToken.accessToken)
        XCTAssertEqual(loadedToken?.refreshToken, testToken.refreshToken)
        XCTAssertEqual(loadedToken?.expiresAt.timeIntervalSince1970, testToken.expiresAt.timeIntervalSince1970, accuracy: 1.0)
    }

    func testHasValidTokensReturnsTrueForNonExpiredToken() throws {
        // Given a non-expired token
        let futureDate = Date().addingTimeInterval(3600)
        let testToken = AuthToken(
            accessToken: "test-access",
            refreshToken: "test-refresh",
            expiresAt: futureDate
        )

        // When saved
        try tokenStorage.save(testToken)

        // Then hasValidTokens returns true
        XCTAssertTrue(tokenStorage.hasValidTokens())
    }

    func testHasValidTokensReturnsFalseForExpiredToken() throws {
        // Given an expired token
        let pastDate = Date().addingTimeInterval(-3600)
        let testToken = AuthToken(
            accessToken: "test-access",
            refreshToken: "test-refresh",
            expiresAt: pastDate
        )

        // When saved
        try tokenStorage.save(testToken)

        // Then hasValidTokens returns false
        XCTAssertFalse(tokenStorage.hasValidTokens())
    }

    func testClearRemovesAllTokens() throws {
        // Given a saved token
        let futureDate = Date().addingTimeInterval(3600)
        let testToken = AuthToken(
            accessToken: "test-access",
            refreshToken: "test-refresh",
            expiresAt: futureDate
        )
        try tokenStorage.save(testToken)
        XCTAssertNotNil(tokenStorage.load())

        // When clear is called
        tokenStorage.clear()

        // Then no token is loaded
        XCTAssertNil(tokenStorage.load())
        XCTAssertFalse(tokenStorage.hasValidTokens())
    }

    func testAccessibilityIsAfterFirstUnlock() {
        // Verify the accessibility setting is correctly set for tvOS persistence
        // This is just a compile-time check that the property is accessible
        // The actual accessibility is set in init and used during saves
        XCTAssertTrue(keychain.accessibility == .afterFirstUnlock, "Keychain accessibility should be .afterFirstUnlock for tvOS persistence")
    }
}
