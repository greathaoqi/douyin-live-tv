//
//  StatisticsOverlay.swift
//  DouyinLiveTV
//
//  Statistics overlay view displaying live room statistics in top-leading corner.
//  Follows tvOS couch-distance readability contract with large font sizes.
//

import SwiftUI
import DouyinLiveTVDomain

public struct StatisticsOverlay: View {
    private let stats: LiveStats
    private let roomTitle: String

    public init(stats: LiveStats, roomTitle: String) {
        self.stats = stats
        self.roomTitle = roomTitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Room title with live/offline status badge (LIVE-05)
            HStack(spacing: 16) {
                Text(roomTitle)
                    .font(.system(size: 36, weight: .semibold))

                Circle()
                    .fill(stats.isLive ? Color.green : Color.red)
                    .frame(width: 20, height: 20)
            }

            Spacer()

            // Viewer Count (LIVE-01, LIVE-04)
            statsItem(label: "Viewers", value: stats.viewerCount)

            // Like Count (LIVE-01, LIVE-04)
            statsItem(label: "Likes", value: stats.likeCount)

            // Total Gifts (LIVE-01, LIVE-04)
            statsItem(label: "Total Gifts", value: stats.totalGiftValue)
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .allowsHitTesting(false) // Don't block interaction with player underneath
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func statsItem(label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 36, weight: .regular))
                .foregroundColor(.secondary)

            Text("\(value)")
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// Preview support
#Preview {
    let previewStats = LiveStats(
        viewerCount: 12580,
        likeCount: 456200,
        totalGiftValue: 128450,
        isLive: true,
        startTime: nil
    )
    return StatisticsOverlay(stats: previewStats, roomTitle: "Douyin Live Room")
        .background(Color.black)
}
