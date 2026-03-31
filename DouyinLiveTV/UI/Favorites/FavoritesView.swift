//
//  FavoritesView.swift
//  DouyinLiveTV
//
//  Created on 2026-03-31.
//

import SwiftUI
import SwiftData
import DouyinLiveTVDomain

struct FavoritesView: View {
    @Binding var selectedTab: Tab
    @Query(sort: \LiveRoom.lastViewed, order: .reverse) private var rooms: [LiveRoom]
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false

    private let favoritesService = DependencyContainer.shared.favoritesService

    var body: some View {
        NavigationStack {
            if rooms.isEmpty {
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
            } else {
                List {
                    ForEach(rooms) { room in
                        FavoriteRoomCell(room: room)
                            .contentShape(Rectangle)
                            .onTapGesture {
                                Task {
                                    try? await favoritesService.updateLastViewed(room)
                                    favoritesService.saveLastSelectedRoomId(room.roomId)
                                    selectedTab = .watchLive
                                }
                            }
                    }
                    .onDelete(perform: deleteRoom)
                }
                .environment(\.editMode, $isEditing)
                .navigationTitle("Favorites")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isEditing ? "Done" : "Edit") {
                            isEditing.toggle()
                        }
                        .focusable()
                        .focusEffect()
                        .frame(minHeight: 88)
                    }
                }
            }
        }
    }

    private func deleteRoom(at offsets: IndexSet) {
        Task {
            for offset in offsets {
                let room = rooms[offset]
                try? await favoritesService.deleteRoom(room)
            }
        }
    }
}

#Preview {
    FavoritesView(selectedTab: .constant(.favorites))
}
