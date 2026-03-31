//
//  DouyinLiveTVApp.swift
//  DouyinLiveTV
//
//  App entry point that checks for stored authentication credentials on launch.
//  Implements session persistence requirement (AUTH-03).
//

import SwiftUI
import SwiftData

@main
struct DouyinLiveTVApp: App {
    private let authStateManager = DependencyContainer.shared.authStateManager
    @State private var initialRoomId: String? = nil

    init() {
        // Get last selected room ID from favorites service on app launch
        initialRoomId = DependencyContainer.shared.favoritesService.getLastSelectedRoomId()
        // Register background refresh on app launch
        DependencyContainer.shared.refreshService.registerBackgroundRefresh()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(initialRoomId: initialRoomId)
                .environment(\.managedObjectContext, DependencyContainer.shared.modelContainer.mainContext)
                .onAppear {
                    authStateManager.checkStoredCredentials()
                }
                .onContinueUserActivity("com.douyinlivedtv.openRoom") { userActivity in
                    if let roomId = userActivity.userInfo?["roomId"] as? String {
                        initialRoomId = roomId
                    }
                }
        }
    }
}
