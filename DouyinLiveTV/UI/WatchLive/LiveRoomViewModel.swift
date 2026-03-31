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

    @Published public private(set) var stats: LiveStats?
    @Published public private(set) var showOverlay: Bool = true
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?
    @Published public var roomTitle: String = ""

    private var cancellables = Set<AnyCancellable>()

    public init(
        playerService: PlayerService,
        liveStatsService: LiveStatsService,
        appLifecycleService: AppLifecycleService
    ) {
        self.playerService = playerService
        self.liveStatsService = liveStatsService
        self.appLifecycleService = appLifecycleService

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
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
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
