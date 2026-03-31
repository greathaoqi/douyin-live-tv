//
//  FavoriteRoomCell.swift
//  DouyinLiveTV
//
//  Created on 2026-03-31.
//

import SwiftUI
import DouyinLiveTVDomain

struct FavoriteRoomCell: View {
    let room: LiveRoom

    private var relativeLastChecked: String {
        let interval = Date().timeIntervalSince(room.lastChecked)
        if interval < 60 {
            return "\(Int(interval))s ago"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(room.title)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(room.nickname)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 16) {
                Circle()
                    .fill(room.isLive ? Color.green : Color.gray)
                    .frame(width: 16, height: 16)

                Text("Checked: \(relativeLastChecked)")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .frame(minHeight: 88)
        .background(Color.secondarySystemBackground)
        .cornerRadius(8)
        .focusable()
        .focusEffect()
    }
}

#Preview {
    FavoriteRoomCell(room: LiveRoom(
        roomId: "123456789",
        title: "Sample Live Room Title",
        nickname: "Author Name",
        avatarUrl: nil,
        isLive: true,
        lastChecked: Date().addingTimeInterval(-300),
        lastViewed: Date()
    ))
    .frame(width: 1200)
}
