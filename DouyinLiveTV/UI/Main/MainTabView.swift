//
//  MainTabView.swift
//  DouyinLiveTV
//
//  Created on 2026-03-31.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .watchLive
    private let initialRoomId: String?

    init(initialRoomId: String? = nil) {
        self.initialRoomId = initialRoomId
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            WatchLiveView(initialRoomId: initialRoomId)
                .tabItem {
                    Label(Tab.watchLive.title, systemImage: Tab.watchLive.systemImage)
                }
                .tag(Tab.watchLive)

            FavoritesView(selectedTab: $selectedTab)
                .tabItem {
                    Label(Tab.favorites.title, systemImage: Tab.favorites.systemImage)
                }
                .tag(Tab.favorites)

            AddRoomView(selectedTab: $selectedTab)
                .tabItem {
                    Label(Tab.addRoom.title, systemImage: Tab.addRoom.systemImage)
                }
                .tag(Tab.addRoom)
        }
        .tabViewStyle(.tabBar)
        .safeAreaPadding()
        .background(Color.systemBackground)
    }
}

#Preview {
    MainTabView()
}
