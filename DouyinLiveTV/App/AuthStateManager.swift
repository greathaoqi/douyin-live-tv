//
//  AuthStateManager.swift
//  DouyinLiveTV
//
//  Main actor-managed authentication state observer for UI observation.
//  Does not cache tokens - tokens are stored only in TokenStorage (Keychain) per D-04.
//

import Foundation
import Observation

@MainActor
@Observable
public class AuthStateManager {
    public enum State: Equatable {
        case unauthenticated
        case authenticating
        case authenticated
    }

    public private(set) var state: State = .unauthenticated

    private let tokenStorage: TokenStorage

    public init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
    }

    /// Checks for stored valid credentials on app launch and updates state accordingly.
    public func checkStoredCredentials() {
        if tokenStorage.hasValidTokens() {
            state = .authenticated
        } else {
            state = .unauthenticated
        }
    }

    /// Logs out the current user by clearing tokens from Keychain and updating state.
    public func logout() {
        tokenStorage.clear()
        state = .unauthenticated
    }

    /// Transitions the authentication state to a new value.
    /// - Parameter newState: The new state to transition to.
    public func transition(to newState: State) {
        state = newState
    }
}
