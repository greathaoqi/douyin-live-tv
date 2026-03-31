//
//  FavoritesView.swift
//  DouyinLiveTV
//
//  Created on 2026-03-31.
//

import SwiftUI

struct FavoritesView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        VStack(spacing: 24) {
            Text("No Favorites Yet")
                .font(.system(size: 60, weight: .bold))
            Text("Add your first live room to start monitoring statistics from the big screen.")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaPadding()
    }
}

#Preview {
    FavoritesView(selectedTab: .constant(.favorites))
}
