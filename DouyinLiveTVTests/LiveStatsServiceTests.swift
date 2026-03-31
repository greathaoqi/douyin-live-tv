//
//  LiveStatsServiceTests.swift
//  DouyinLiveTVTests
//
//  Unit tests for LiveStatsService API integration and decoding.
//

import XCTest
@testable import DouyinLiveTV
@testable import DouyinLiveTVDomain

final class LiveStatsServiceTests: XCTestCase {
    // MARK: - LiveStats Decoding Tests

    func testLiveStatsDecoding_success() throws {
        // Given
        let json = """
        {
            "viewerCount": 1234,
            "likeCount": 56789,
            "totalGiftValue": 12345,
            "isLive": true,
            "startTime": 1704067200
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stats = try decoder.decode(LiveStats.self, from: json)

        // Then
        XCTAssertEqual(stats.viewerCount, 1234)
        XCTAssertEqual(stats.likeCount, 56789)
        XCTAssertEqual(stats.totalGiftValue, 12345)
        XCTAssertEqual(stats.isLive, true)
        XCTAssertNotNil(stats.startTime)
    }

    func testLiveStatsDecoding_isLiveFalse() throws {
        // Given
        let json = """
        {
            "viewerCount": 0,
            "likeCount": 0,
            "totalGiftValue": 0,
            "isLive": false,
            "startTime": null
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stats = try decoder.decode(LiveStats.self, from: json)

        // Then
        XCTAssertEqual(stats.isLive, false)
        XCTAssertNil(stats.startTime)
    }

    func testEndpointConfiguration_hasCorrectParameters() {
        // Given
        let roomId = "123456"
        let endpoint = Endpoint.getLiveStats(roomId: roomId)

        // Then
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.path, "/live/room/stats")
        XCTAssertEqual(endpoint.parameters?["room_id"] as? String, roomId)
        XCTAssertNotNil(endpoint.headers?["Accept"])
        XCTAssertNotNil(endpoint.headers?["User-Agent"])
    }
}
