//
//  RefreshService.swift
//  DouyinLiveTV
//
//  Service for automatic background refresh using BackgroundTasks framework
//  and foreground timer for periodic refresh of favorite room live status.
//

import Foundation
import BackgroundTasks
import Combine
import SwiftData
import DouyinLiveTVDomain

public class RefreshService {
    // Dependencies
    private let favoritesService: FavoritesService
    private let liveStatsService: LiveStatsService
    private let appLifecycleService: AppLifecycleService
    private let modelContainer: ModelContainer

    // Refresh interval: 30 minutes as per requirements
    private let refreshInterval: TimeInterval = 30 * 60

    // Foreground refresh timer
    private var foregroundTimer: Timer?

    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()

    // Background task identifier
    private let backgroundRefreshIdentifier = "\(Bundle.main.bundleIdentifier!).refresh"

    public init(
        favoritesService: FavoritesService,
        liveStatsService: LiveStatsService,
        appLifecycleService: AppLifecycleService,
        modelContainer: ModelContainer
    ) {
        self.favoritesService = favoritesService
        self.liveStatsService = liveStatsService
        self.appLifecycleService = appLifecycleService
        self.modelContainer = modelContainer

        setupLifecycleObservation()
    }

    private func setupLifecycleObservation() {
        appLifecycleService.$currentState
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .foreground:
                    self.startForegroundRefresh()
                case .background:
                    self.stopForegroundRefresh()
                    self.scheduleNextRefresh()
                }
            }
            .store(in: &cancellables)
    }

    public func registerBackgroundRefresh() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundRefreshIdentifier,
            using: nil
        ) { [weak self] task in
            guard let self = self, let refreshTask = task as? BGAppRefreshTask else { return }
            self.handleBackgroundRefresh(refreshTask)
        }
    }

    public func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundRefreshIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: refreshInterval)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background refresh: \(error.localizedDescription)")
        }
    }

    public func handleBackgroundRefresh(_ task: BGAppRefreshTask) {
        // Schedule the next refresh immediately after starting this one
        scheduleNextRefresh()

        task.expirationHandler = {
            // Task is being expired by the system, we can't do anything more
            task.setTaskCompleted(success: false)
        }

        Task {
            do {
                try await refreshAllFavorites()
                task.setTaskCompleted(success: true)
            } catch {
                print("Background refresh failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
    }

    public func startForegroundRefresh() {
        // Invalidate any existing timer
        stopForegroundRefresh()

        // Create a new repeating timer
        foregroundTimer = Timer.scheduledTimer(
            withTimeInterval: refreshInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            Task {
                do {
                    try await self.refreshAllFavorites()
                } catch {
                    print("Foreground refresh failed: \(error.localizedDescription)")
                }
            }
        }
    }

    public func stopForegroundRefresh() {
        foregroundTimer?.invalidate()
        foregroundTimer = nil
    }

    public func refreshAllFavorites() async throws {
        let favorites = try await favoritesService.fetchFavorites()
        let context = modelContainer.mainContext

        for room in favorites {
            do {
                let stats = try await liveStatsService.fetchStats(for: room.roomId)
                room.isLive = stats.isLive
                room.lastChecked = Date()

                // Update other metadata in case it changed
                room.title = stats.title
                room.nickname = stats.nickname
                room.avatarUrl = stats.avatarUrl
                room.streamURL = stats.streamURL
            } catch {
                print("Failed to refresh room \(room.roomId): \(error.localizedDescription)")
                // Continue with other rooms even if one fails
            }
        }

        try context.save()
    }
}
