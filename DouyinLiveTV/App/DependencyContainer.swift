//
//  DependencyContainer.swift
//  DouyinLiveTV
//
//  Simple manual dependency injection container for the small app.
//  Avoids third-party DI framework complexity.
//

import Foundation
import SwiftData
import DouyinLiveTVDomain

class DependencyContainer {
    static let shared = DependencyContainer()

    // SwiftData model container
    let modelContainer: ModelContainer

    // Authentication dependencies
    public let tokenStorage: TokenStorage
    public let apiClient: APIClient
    public let authService: AuthService
    public let authStateManager: AuthStateManager

    // App lifecycle dependencies
    public let appLifecycleService: AppLifecycleService

    // Live playback dependencies
    public let playerService: PlayerService
    public let liveStatsService: LiveStatsService

    // Favorites dependencies
    public let favoritesService: FavoritesService

    // Automatic refresh dependencies
    public let refreshService: RefreshService

    private init() {
        // Configure SwiftData model container
        do {
            self.modelContainer = try ModelContainer(for: [LiveRoom.self])
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }

        // Initialize app lifecycle dependencies
        self.appLifecycleService = AppLifecycleService()

        // Initialize authentication dependencies
        self.tokenStorage = TokenStorage()
        self.apiClient = APIClient()
        self.authStateManager = AuthStateManager(tokenStorage: self.tokenStorage)
        self.authService = AuthService(
            tokenStorage: self.tokenStorage,
            apiClient: self.apiClient,
            authStateManager: self.authStateManager
        )

        // Initialize live playback dependencies
        self.playerService = PlayerService()
        self.liveStatsService = LiveStatsService(apiClient: self.apiClient, authService: self.authService)

        // Initialize favorites dependencies
        self.favoritesService = FavoritesService(
            modelContainer: self.modelContainer,
            liveStatsService: self.liveStatsService
        )

        // Initialize automatic refresh dependencies
        self.refreshService = RefreshService(
            favoritesService: self.favoritesService,
            liveStatsService: self.liveStatsService,
            appLifecycleService: self.appLifecycleService,
            modelContainer: self.modelContainer
        )
    }
}
