//
//  AppLifecycleTests.swift
//  DouyinLiveTVTests
//
//  Unit tests for app lifecycle observation.
//

import XCTest
import Combine
@testable import DouyinLiveTV

class AppLifecycleTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        cancellables.removeAll()
    }

    override func tearDownWithError() throws {
        cancellables.removeAll()
    }

    func testInitialStateIsForeground() throws {
        let service = AppLifecycleService()
        XCTAssertEqual(service.currentState, .foreground)
    }

    func testDidEnterBackgroundNotificationChangesStateToBackground() throws {
        let service = AppLifecycleService()
        let expectation = XCTestExpectation(description: "State changes to background")

        service.$currentState
            .dropFirst()
            .sink { state in
                XCTAssertEqual(state, .background)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        NotificationCenter.default.post(
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(service.currentState, .background)
    }

    func testWillEnterForegroundNotificationChangesStateToForeground() throws {
        let service = AppLifecycleService()

        // First go to background
        let backgroundExpectation = XCTestExpectation(description: "State changes to background")
        service.$currentState
            .dropFirst()
            .sink { state in
                if state == .background {
                    backgroundExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.post(
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        wait(for: [backgroundExpectation], timeout: 1.0)

        // Then go back to foreground
        let foregroundExpectation = XCTestExpectation(description: "State changes to foreground")
        service.$currentState
            .sink { state in
                if state == .foreground {
                    foregroundExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.post(
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        wait(for: [foregroundExpectation], timeout: 1.0)
        XCTAssertEqual(service.currentState, .foreground)
    }
}
