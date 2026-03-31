//
//  LiveRoomViewModel.swift
//  DouyinLiveTV
//
//  View model managing UI state and business logic for the live room display.
//  Orchestrates stats fetching, player control, and app lifecycle integration.
//

import Combine
import SwiftUI
import AVKit
import DouyinLiveTVDomain
import DouyinLiveTVData

public class LiveRoomViewModel: ObservableObject {
    private let playerService: PlayerService
    private let liveStatsService: LiveStatsService
    private let appLifecycleService: AppLifecycleService
    public let initialRoomId: String?

    @Published public private(set) var stats: LiveStats?
    @Published public private(set) var showOverlay: Bool = true
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?
    @Published public var roomTitle: String = ""

    private var currentRoomId: String?
    private var currentStreamURL: URL?
    private var cancellables = Set<AnyCancellable>()

    public init(
        playerService: PlayerService,
        liveStatsService: LiveStatsService,
        appLifecycleService: AppLifecycleService,
        initialRoomId: String? = nil
    ) {
        self.playerService = playerService
        self.liveStatsService = liveStatsService
        self.appLifecycleService = appLifecycleService
        self.initialRoomId = initialRoomId

        subscribeToAppLifecycle()
    }

    deinit {
        cancellables.removeAll()
    }

    /// Toggles the statistics overlay visibility (required by LIVE-06)
    public func toggleOverlay() {
        showOverlay.toggle()
    }

    /// Loads the live room with the given room ID and stream URL
    /// - Parameters:
    ///   - roomId: The unique identifier for the live room
    ///   - streamURL: Optional URL to the live stream (can be nil if only stats needed)
    public func loadRoom(roomId: String, streamURL: URL?) async {
        isLoading = true
        errorMessage = nil

        do {
            if let streamURL = streamURL {
                playerService.loadVideo(url: streamURL)
                playerService.play()
            }

            stats = try await liveStatsService.fetchStats(for: roomId)
            currentRoomId = roomId
            currentStreamURL = streamURL

            // If streamURL was nil but API returned a streamURL, load it now
            if currentStreamURL == nil, let streamURLString = stats?.streamURL, let streamURL = URL(string: streamURLString) {
                playerService.loadVideo(url: streamURL)
                playerService.play()
                currentStreamURL = streamURL
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Refreshes the current live room statistics by fetching the latest data from the API
    /// - Note: Does nothing if no room is currently loaded
    public func refresh() async {
        guard let roomId = currentRoomId else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            stats = try await liveStatsService.fetchStats(for: roomId)
            isLoading = false
        } catch {
            errorMessage = "Could not refresh live room data. Pull to try again."
            isLoading = false
        }
    }

    private func subscribeToAppLifecycle() {
        appLifecycleService.$currentState
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .background:
                    self.playerService.pause()
                case .foreground:
                    self.playerService.resume()
                }
            }
            .store(in: &cancellables)
    }
}
