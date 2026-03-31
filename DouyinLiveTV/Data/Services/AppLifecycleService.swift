//
//  AppLifecycleService.swift
//  DouyinLiveTV
//
//  Service for observing app lifecycle state changes.
//

import UIKit
import Combine

public class AppLifecycleService {
    @Published public private(set) var currentState: AppLifecycleState = .foreground

    private var cancellables = Set<AnyCancellable>()

    public init() {
        setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default.publisher(
            for: UIApplication.didEnterBackgroundNotification
        )
        .sink { [weak self] _ in
            self?.currentState = .background
        }
        .store(in: &cancellables)

        NotificationCenter.default.publisher(
            for: UIApplication.willEnterForegroundNotification
        )
        .sink { [weak self] _ in
            self?.currentState = .foreground
        }
        .store(in: &cancellables)
    }
}
