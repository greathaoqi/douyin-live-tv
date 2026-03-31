//
//  LiveRoomViewModelTests.swift
//  DouyinLiveTVTests
//
//  Unit tests for LiveRoomViewModel behavior
//

import XCTest
import Combine
@testable import DouyinLiveTV

final class LiveRoomViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testInitialState_HasShowOverlayTrue() {
        // Given
        let viewModel = makeViewModel()

        // Then
        XCTAssertTrue(viewModel.showOverlay, "Initial showOverlay should be true per requirement LIVE-03")
    }

    func testToggleOverlay_FlipsFromTrueToFalse() {
        // Given
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.showOverlay)

        // When
        viewModel.toggleOverlay()

        // Then
        XCTAssertFalse(viewModel.showOverlay, "toggleOverlay should flip to false")

        // When toggled again
        viewModel.toggleOverlay()

        // Then
        XCTAssertTrue(viewModel.showOverlay, "toggleOverlay should flip back to true")
    }

    // MARK: - Test Helpers

    private func makeViewModel() -> LiveRoomViewModel {
        let playerService = PlayerService()
        let apiClient = APIClient()
        let liveStatsService = LiveStatsService(apiClient: apiClient)
        let appLifecycleService = AppLifecycleService()
        return LiveRoomViewModel(
            playerService: playerService,
            liveStatsService: liveStatsService,
            appLifecycleService: appLifecycleService
        )
    }
}
