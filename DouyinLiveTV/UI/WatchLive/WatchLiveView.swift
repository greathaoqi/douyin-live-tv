//
//  WatchLiveView.swift
//  DouyinLiveTV
//
//  Created on 2026-03-31.
//

import SwiftUI

struct WatchLiveView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Watch Live")
                .font(.largeTitle)
            Text("Coming in Phase 4")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaPadding()
    }
}

#Preview {
    WatchLiveView()
}
