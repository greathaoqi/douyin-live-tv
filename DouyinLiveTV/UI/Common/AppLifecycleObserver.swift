//
//  AppLifecycleObserver.swift
//  DouyinLiveTV
//
//  ObservableObject for observing app lifecycle changes in SwiftUI views.
//

import UIKit
import Combine
import SwiftUI

public class AppLifecycleObserver: ObservableObject {
    @Published public private(set) var isInBackground: Bool = false

    private let appLifecycleService: AppLifecycleService
    private var cancellables = Set<AnyCancellable>()

    public init(appLifecycleService: AppLifecycleService) {
        self.appLifecycleService = appLifecycleService
        setupSynchronization()
    }

    private func setupSynchronization() {
        // Sync initial state
        isInBackground = appLifecycleService.currentState == .background

        // Sync future state changes
        appLifecycleService.$currentState
            .map { $0 == .background }
            .assign(to: &$isInBackground)
    }
}
