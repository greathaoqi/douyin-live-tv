//
//  LiveStats.swift
//  DouyinLiveTV
//
//  Codable model representing live room statistics from Douyin API
//

import Foundation

struct LiveStats: Codable, Equatable {
    let title: String
    let nickname: String
    let avatarUrl: String?
    let viewerCount: Int
    let likeCount: Int
    let totalGiftValue: Int
    let isLive: Bool
    let startTime: Date?
    let streamURL: String?

    init(
        title: String,
        nickname: String,
        avatarUrl: String? = nil,
        viewerCount: Int,
        likeCount: Int,
        totalGiftValue: Int,
        isLive: Bool,
        startTime: Date?,
        streamURL: String? = nil
    ) {
        self.title = title
        self.nickname = nickname
        self.avatarUrl = avatarUrl
        self.viewerCount = viewerCount
        self.likeCount = likeCount
        self.totalGiftValue = totalGiftValue
        self.isLive = isLive
        self.startTime = startTime
        self.streamURL = streamURL
    }
}
