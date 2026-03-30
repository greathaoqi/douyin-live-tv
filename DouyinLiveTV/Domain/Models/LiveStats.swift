//
//  LiveStats.swift
//  DouyinLiveTV
//
//  Codable model representing live room statistics from Douyin API
//

import Foundation

struct LiveStats: Codable, Equatable {
    let viewerCount: Int
    let likeCount: Int
    let totalGiftValue: Int
    let isLive: Bool
    let startTime: Date?

    init(
        viewerCount: Int,
        likeCount: Int,
        totalGiftValue: Int,
        isLive: Bool,
        startTime: Date?
    ) {
        self.viewerCount = viewerCount
        self.likeCount = likeCount
        self.totalGiftValue = totalGiftValue
        self.isLive = isLive
        self.startTime = startTime
    }
}
