//
//  LiveRoom.swift
//  DouyinLiveTV
//
//  Core domain model representing a saved live room (SwiftData)
//

import Foundation
import SwiftData

@Model
class LiveRoom {
    @Attribute(.unique) var roomId: String
    var title: String
    var nickname: String
    var avatarUrl: String?
    var streamURL: String?
    var isLive: Bool
    var lastChecked: Date
    var lastViewed: Date?

    init(
        roomId: String,
        title: String,
        nickname: String,
        avatarUrl: String? = nil,
        streamURL: String? = nil,
        isLive: Bool = false,
        lastChecked: Date = Date(),
        lastViewed: Date? = nil
    ) {
        self.roomId = roomId
        self.title = title
        self.nickname = nickname
        self.avatarUrl = avatarUrl
        self.streamURL = streamURL
        self.isLive = isLive
        self.lastChecked = lastChecked
        self.lastViewed = lastViewed
    }
}
