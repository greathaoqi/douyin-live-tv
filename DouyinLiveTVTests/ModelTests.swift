//
//  ModelTests.swift
//  DouyinLiveTVTests
//
//  Unit tests for core domain model decoding and behavior
//

import XCTest
import SwiftData
@testable import DouyinLiveTV

final class ModelTests: XCTestCase {

    // Test 1: LiveStats can be decoded from sample JSON with all fields present
    func testLiveStatsDecodingWithAllFields() throws {
        let json = """
        {
            "viewerCount": 12500,
            "likeCount": 45800,
            "totalGiftValue": 12800,
            "isLive": true,
            "startTime": 1700000000
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stats = try decoder.decode(LiveStats.self, from: json)

        XCTAssertEqual(stats.viewerCount, 12500)
        XCTAssertEqual(stats.likeCount, 45800)
        XCTAssertEqual(stats.totalGiftValue, 12800)
        XCTAssertEqual(stats.isLive, true)
        XCTAssertNotNil(stats.startTime)
    }

    // Test 2: LiveStats decodes correctly with optional startTime nil
    func testLiveStatsDecodingWithNilStartTime() throws {
        let json = """
        {
            "viewerCount": 0,
            "likeCount": 0,
            "totalGiftValue": 0,
            "isLive": false
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let stats = try decoder.decode(LiveStats.self, from: json)

        XCTAssertEqual(stats.viewerCount, 0)
        XCTAssertEqual(stats.likeCount, 0)
        XCTAssertEqual(stats.totalGiftValue, 0)
        XCTAssertEqual(stats.isLive, false)
        XCTAssertNil(stats.startTime)
    }

    // Test 3: LiveRoom can be instantiated with all required properties
    func testLiveRoomInstantiation() throws {
        let room = LiveRoom(
            roomId: "12345678",
            title: "Test Live Room",
            nickname: "Test Creator",
            avatarUrl: "https://example.com/avatar.jpg",
            isLive: true,
            lastChecked: Date(timeIntervalSince1970: 1700000000),
            lastViewed: Date(timeIntervalSince1970: 1700001000)
        )

        XCTAssertEqual(room.roomId, "12345678")
        XCTAssertEqual(room.title, "Test Live Room")
        XCTAssertEqual(room.nickname, "Test Creator")
        XCTAssertEqual(room.avatarUrl, "https://example.com/avatar.jpg")
        XCTAssertEqual(room.isLive, true)
        XCTAssertEqual(room.lastChecked.timeIntervalSince1970, 1700000000)
        XCTAssertEqual(room.lastViewed?.timeIntervalSince1970, 1700001000)
    }

    // Test 4: LiveRoom instantiation with optional fields nil
    func testLiveRoomInstantiationWithOptionalsNil() throws {
        let room = LiveRoom(
            roomId: "87654321",
            title: "Another Room",
            nickname: "Another Creator",
            avatarUrl: nil,
            isLive: false,
            lastChecked: Date()
        )

        XCTAssertEqual(room.roomId, "87654321")
        XCTAssertEqual(room.title, "Another Room")
        XCTAssertEqual(room.nickname, "Another Creator")
        XCTAssertNil(room.avatarUrl)
        XCTAssertEqual(room.isLive, false)
        XCTAssertNotNil(room.lastChecked)
        XCTAssertNil(room.lastViewed)
    }

    // Test 5: LiveStats equality conformance works correctly
    func testLiveStatsEquality() throws {
        let stats1 = LiveStats(
            viewerCount: 100,
            likeCount: 200,
            totalGiftValue: 300,
            isLive: true,
            startTime: Date(timeIntervalSince1970: 1700000000)
        )

        let stats2 = LiveStats(
            viewerCount: 100,
            likeCount: 200,
            totalGiftValue: 300,
            isLive: true,
            startTime: Date(timeIntervalSince1970: 1700000000)
        )

        let stats3 = LiveStats(
            viewerCount: 101,
            likeCount: 200,
            totalGiftValue: 300,
            isLive: true,
            startTime: Date(timeIntervalSince1970: 1700000000)
        )

        XCTAssertEqual(stats1, stats2)
        XCTAssertNotEqual(stats1, stats3)
    }
}
