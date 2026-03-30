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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, DependencyContainer.shared.modelContainer.mainContext)
                .onAppear {
                    authStateManager.checkStoredCredentials()
                }
        }
    }
}
