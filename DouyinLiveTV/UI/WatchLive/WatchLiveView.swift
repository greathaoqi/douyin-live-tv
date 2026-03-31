//
//  WatchLiveView.swift
//  DouyinLiveTV
//
//  Main live room view that displays full-screen video with statistics overlay.
//  Composes all components created in this phase into a complete feature.
//
//  Requirements satisfied:
//  - LIVE-01: Basic statistics displayed (via StatisticsOverlay)
//  - LIVE-02: Live video preview via AVPlayer (native VideoPlayer)
//  - LIVE-03: Statistics overlay on top of video (ZStack layout)
//  - LIVE-06: Toggle between overlay and full-screen (OverlayToggleButton)
//  - LIVE-07: Picture in Picture support (enabled by PlayerService)
//

import SwiftUI
import AVKit
import DouyinLiveTVDomain

struct WatchLiveView: View {
    @StateObject private var viewModel: LiveRoomViewModel
    @State private var loadedRoomId: String? = nil

    // Initialize with dependencies from DependencyContainer
    init() {
        let playerService = DependencyContainer.shared.playerService
        let liveStatsService = DependencyContainer.shared.liveStatsService
        let appLifecycleService = DependencyContainer.shared.appLifecycleService
        _viewModel = StateObject(wrappedValue: LiveRoomViewModel(
            playerService: playerService,
            liveStatsService: liveStatsService,
            appLifecycleService: appLifecycleService
        ))
    }

    // For preview with mock data
    fileprivate init(viewModel: LiveRoomViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background: black behind video
            Color.black
                .ignoresSafeArea()

            // Full-screen VideoPlayer (LIVE-02)
            if let player = viewModel.playerService.player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            }

            // Statistics Overlay (LIVE-03) - only show when overlay enabled and stats available
            if viewModel.showOverlay, let stats = viewModel.stats {
                StatisticsOverlay(stats: stats, roomTitle: viewModel.roomTitle)
                    .padding(.safeAreaPadding)
                    .opacity(viewModel.showOverlay ? 1 : 0)
                    .animation(.default, value: viewModel.showOverlay)
            }

            // Overlay Toggle Button (LIVE-06) - top-trailing corner
            VStack {
                HStack {
                    Spacer()
                    OverlayToggleButton(
                        showingOverlay: viewModel.showOverlay,
                        action: viewModel.toggleOverlay
                    )
                }
                Spacer()
            }
            .padding(.safeAreaPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // Empty State - no room selected
            if viewModel.stats == nil && !viewModel.isLoading && viewModel.errorMessage == nil {
                emptyState
            }

            // Loading State
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Error State
            if let errorMessage = viewModel.errorMessage, !viewModel.isLoading {
                errorState(errorMessage: errorMessage)
            }
        }
        .onAppear {
            // Load last viewed room from UserDefaults if available
            if let lastRoomId = UserDefaults.standard.string(forKey: "LastViewedRoomId"),
               let lastStreamURLString = UserDefaults.standard.string(forKey: "LastViewedStreamURL"),
               let lastStreamURL = URL(string: lastStreamURLString),
               let lastRoomTitle = UserDefaults.standard.string(forKey: "LastViewedRoomTitle") {
                loadedRoomId = lastRoomId
                viewModel.roomTitle = lastRoomTitle
                Task {
                    await viewModel.loadRoom(roomId: lastRoomId, streamURL: lastStreamURL)
                }
            }
        }
        .onChange(of: viewModel.stats) { newValue in
            // Persist last viewed room when loaded successfully
            if let roomId = loadedRoomId, let stats = newValue {
                UserDefaults.standard.set(roomId, forKey: "LastViewedRoomId")
                UserDefaults.standard.set(viewModel.roomTitle, forKey: "LastViewedRoomTitle")
                // Stream URL would be stored when room is selected from favorites
                // This is temporary until Phase 5 with SwiftData favorites
            }
        }
    }

    // Empty state view when no room selected
    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("No Live Room Selected")
                .font(.system(size: 36, weight: .semibold))
            Text("Select a live room from favorites or add a new one to start monitoring.")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.safeAreaPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Error state view when loading fails
    private func errorState(errorMessage: String) -> some View {
        VStack(spacing: 16) {
            Text("Could not load live room data. Check the room ID and try again.")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.systemRed)
                .multilineTextAlignment(.center)
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.safeAreaPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview Support
#Preview {
    // Preview with mock data showing empty state
    WatchLiveView()
}

// Preview with loaded data
#Preview("Loaded with overlay") {
    let container = DependencyContainer.shared
    let viewModel = LiveRoomViewModel(
        playerService: container.playerService,
        liveStatsService: container.liveStatsService,
        appLifecycleService: container.appLifecycleService
    )
    viewModel.roomTitle = "Sample Live Room"
    viewModel.stats = LiveStats(
        viewerCount: 12580,
        likeCount: 456200,
        totalGiftValue: 128450,
        isLive: true,
        startTime: nil
    )
    viewModel.showOverlay = true
    return WatchLiveView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
