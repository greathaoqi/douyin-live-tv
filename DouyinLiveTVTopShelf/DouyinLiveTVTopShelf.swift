//
//  DouyinLiveTVTopShelf.swift
//  DouyinLiveTVTopShelf
//
//  Top Shelf extension providing quick access to favorite live rooms
//

import Foundation
import SwiftData
import TVTopShelf

class DouyinLiveTVTopShelf: TVTopShelfProvider {
    var topShelfContent: some TVTopShelfContent {
        do {
            // Initialize SwiftData ModelContainer shared with main app
            let container = try ModelContainer(for: [LiveRoom.self])

            // Fetch up to 4 favorites sorted by lastViewed descending (most recently used first)
            let descriptor = FetchDescriptor<LiveRoom>(
                sortBy: [SortDescriptor(\.lastViewed, order: .reverse)],
                range: 0..<4
            )

            let rooms = try container.mainContext.fetch(descriptor)

            if rooms.isEmpty {
                // Empty state - no favorites added yet
                return TVTopShelfTextContent(
                    text: "No favorites added yet. Add a live room in the app to see it here."
                )
            }

            // Create section items
            let items = rooms.map { room in
                let item = TVTopShelfItem()
                item.image = .symbol(name: "tv")
                item.title = room.title
                item.subtitle = room.nickname
                item.badgeColor = room.isLive ? .green : nil
                item.hasBadge = room.isLive

                // Set up user activity for opening this room in the app
                let userActivity = NSUserActivity(activityType: "com.douyinlivedtv.openRoom")
                userActivity.userInfo = ["roomId": room.roomId]
                item.userActivity = userActivity

                return item
            }

            // Create single section with all items
            let section = TVTopShelfSection(items: items)
            return TVTopShelfSectionedContent(sections: [section])

        } catch {
            // Error state - couldn't load favorites
            return TVTopShelfTextContent(
                text: "Could not load favorites. Open the app to refresh."
            )
        }
    }
}
