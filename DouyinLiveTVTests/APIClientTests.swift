//
//  APIClientTests.swift
//  DouyinLiveTVTests
//
//  Unit tests for API client and QR code generation
//
//  This file tests:
//  - QR code generation functionality from Data/Network/QRCodeGenerator.swift
//

import XCTest
import UIKit
@testable import DouyinLiveTV

final class APIClientTests: XCTestCase {

    // Test 1: generateQRCode returns non-nil UIImage for valid input string
    func testGenerateQRCodeReturnsNonNilImageForValidInput() throws {
        let testUUID = "550e8400-e29b-41d4-a716-446655440000"
        let size = CGSize(width: 300, height: 300)

        let image = generateQRCode(from: testUUID, size: size)

        XCTAssertNotNil(image, "QR code should generate non-nil image for valid input")
        XCTAssertEqual(image?.size.width, 300, "Output image should have requested width")
        XCTAssertEqual(image?.size.height, 300, "Output image should have requested height")
    }

    // Test 2: generateQRCode returns nil for empty input
    func testGenerateQRCodeReturnsNilForEmptyInput() throws {
        let emptyString = ""
        let size = CGSize(width: 300, height: 300)

        let image = generateQRCode(from: emptyString, size: size)

        // Empty data results in nil filter output
        XCTAssertNil(image, "QR code generation should return nil for empty input")
    }

    // Test 3: Endpoint can be constructed with correct parameters
    func testEndpointConstructionHasCorrectProperties() throws {
        let endpoint: Endpoint<LoginQRCode> = .getQRCode()

        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.path, "/get_qr_code")
        XCTAssertNil(endpoint.parameters)
        XCTAssertNotNil(endpoint.headers?["User-Agent"])
        XCTAssertNotNil(endpoint.headers?["Accept"])
        XCTAssertEqual(endpoint.headers?["Accept"], "application/json")
    }

    // Test 4: Check QR status endpoint includes uuid as parameter
    func testCheckQRStatusHasUUIDParameter() throws {
        let testUUID = "test-uuid-12345"
        let endpoint: Endpoint<QRStatusResponse> = .checkQRStatus(uuid: testUUID)

        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.path, "/check_qr_status")
        XCTAssertEqual(endpoint.parameters?["uuid"], testUUID)
    }

    // Test 5: QRStatusResponse correctly identifies when tokens are present
    func testQRStatusResponseHasTokensDetection() throws {
        // With all tokens
        let responseWithTokens = QRStatusResponse(
            confirmed: true,
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token",
            expiresAt: Date()
        )
        XCTAssertTrue(responseWithTokens.hasTokens)

        // Missing access token
        let responseMissingAccessToken = QRStatusResponse(
            confirmed: true,
            accessToken: nil,
            refreshToken: "test-refresh-token",
            expiresAt: Date()
        )
        XCTAssertFalse(responseMissingAccessToken.hasTokens)

        // Not confirmed yet, no tokens
        let responsePending = QRStatusResponse(confirmed: false)
        XCTAssertFalse(responsePending.hasTokens)
    }

    // Test 6: AuthToken correctly identifies expired tokens
    func testAuthTokenDetectsExpiredTokens() throws {
        // Expired token in the past
        let expiredToken = AuthToken(
            accessToken: "test",
            refreshToken: "test-refresh",
            expiresAt: Date(timeIntervalSinceNow: -3600)
        )
        XCTAssertTrue(expiredToken.isExpired, "Token in past should be detected as expired")

        // Valid token in the future
        let validToken = AuthToken(
            accessToken: "test",
            refreshToken: "test-refresh",
            expiresAt: Date(timeIntervalSinceNow: 3600)
        )
        XCTAssertFalse(validToken.isExpired, "Token in future should not be detected as expired")
    }
}
