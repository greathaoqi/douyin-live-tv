//
//  FavoritesService.swift
//  DouyinLiveTV
//
//  Service for managing favorite live rooms with SwiftData persistence.
//

import Foundation
import SwiftData
import Combine
import DouyinLiveTVDomain

public class FavoritesService {
    private let modelContainer: ModelContainer
    private let liveStatsService: LiveStatsService

    @Published public private(set) var favorites: [LiveRoom] = []

    private let lastSelectedRoomIdKey = "lastSelectedRoomId"

    public init(modelContainer: ModelContainer, liveStatsService: LiveStatsService) {
        self.modelContainer = modelContainer
        self.liveStatsService = liveStatsService
    }

    public func fetchFavorites() async throws -> [LiveRoom] {
        let descriptor = FetchDescriptor<LiveRoom>(
            sortBy: [
                // Sort by lastViewed descending, nil values go last
                SortDescriptor(\.lastViewed, order: .reverse)
            ]
        )

        let context = modelContainer.mainContext
        let rooms = try context.fetch(descriptor)
        self.favorites = rooms
        return rooms
    }

    public func addRoom(roomId: String) async throws -> LiveRoom {
        let stats = try await liveStatsService.fetchStats(for: roomId)

        let context = modelContainer.mainContext

        // Check if room already exists
        let descriptor = FetchDescriptor<LiveRoom>(
            predicate: #Predicate { $0.roomId == roomId }
        )
        let existingRooms = try context.fetch(descriptor)

        let room: LiveRoom
        if let existing = existingRooms.first {
            room = existing
            // Update metadata from fresh stats
            room.title = stats.title
            room.nickname = stats.nickname
            room.avatarUrl = stats.avatarUrl
            room.isLive = stats.isLive
            room.lastChecked = Date()
        } else {
            room = LiveRoom(
                roomId: roomId,
                title: stats.title,
                nickname: stats.nickname,
                avatarUrl: stats.avatarUrl,
                isLive: stats.isLive,
                lastChecked: Date(),
                lastViewed: Date()
            )
            context.insert(room)
        }

        try context.save()
        try await fetchFavorites()
        return room
    }

    public func deleteRoom(_ room: LiveRoom) async throws {
        let context = modelContainer.mainContext
        context.delete(room)
        try context.save()
        try await fetchFavorites()
    }

    public func updateLastViewed(_ room: LiveRoom) async throws {
        room.lastViewed = Date()
        let context = modelContainer.mainContext
        try context.save()
        try await fetchFavorites()
    }

    public func saveLastSelectedRoomId(_ roomId: String) {
        UserDefaults.standard.set(roomId, forKey: lastSelectedRoomIdKey)
    }

    public func getLastSelectedRoomId() -> String? {
        UserDefaults.standard.string(forKey: lastSelectedRoomIdKey)
    }

    public func extractRoomId(from input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Check if it's already just a numeric ID
        if trimmed.range(of: "^[0-9]+$", options: .regularExpression) != nil {
            return trimmed
        }

        // Check for /video/XXX pattern
        if let range = trimmed.range(of: "/video/([^/]+)$", options: .regularExpression) {
            let videoPart = trimmed[range]
            let id = videoPart.replacingOccurrences(of: "/video/", with: "")
            return !id.isEmpty ? id : nil
        }

        // Check for v.douyin.com/XXX pattern
        if trimmed.contains("v.douyin.com") {
            let components = trimmed.components(separatedBy: "/")
            let id = components.last { !$0.isEmpty }
            return id
        }

        // Check for /user/XXX/live pattern
        if let range = trimmed.range(of: "/user/([^/]+)/live$", options: .regularExpression) {
            let userPart = trimmed[range]
            let id = userPart.replacingOccurrences(of: "/user/", with: "")
                              .replacingOccurrences(of: "/live", with: "")
            return !id.isEmpty ? id : nil
        }

        // If all else fails, just return the trimmed input
        // This handles URLs with room ID in query params or other formats
        return trimmed
    }
}
