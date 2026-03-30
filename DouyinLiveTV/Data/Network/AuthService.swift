//
//  AuthService.swift
//  DouyinLiveTV
//
//  Core authentication service handling QR login flow, polling, and automatic token refresh.
//  Actor-based to prevent race conditions with concurrent token refresh and API requests.
//

import Foundation
import DouyinLiveTVDomain

public actor AuthService {
    private let tokenStorage: TokenStorage
    private let apiClient: APIClient
    private weak var authStateManager: AuthStateManager?

    private var pollingTask: Task<Void, Error>?

    public init(
        tokenStorage: TokenStorage,
        apiClient: APIClient,
        authStateManager: AuthStateManager?
    ) {
        self.tokenStorage = tokenStorage
        self.apiClient = apiClient
        self.authStateManager = authStateManager
    }

    // MARK: - QR Login Flow

    /// Starts QR login flow by fetching a QR code from the server and begins polling for confirmation.
    /// - Returns: The LoginQRCode containing the QR URL and UUID for UI display.
    /// - Throws: Any error from the API request.
    public func startQRLogin() async throws -> LoginQRCode {
        let qrCode = try await apiClient.request(.getQRCode())
        authStateManager?.transition(to: .authenticating)
        startPolling(for: qrCode.uuid)
        return qrCode
    }

    /// Starts background polling for QR login confirmation.
    /// Polls every 2.5 seconds for up to 2 minutes (48 attempts).
    /// - Parameter uuid: The QR code UUID to check.
    private func startPolling(for uuid: String) {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            try await self?.pollForConfirmation(uuid: uuid)
        }
    }

    /// Polls the server repeatedly to check if the QR code has been confirmed by the user.
    /// - Parameter uuid: The QR code UUID to check.
    /// - Throws: `APIError` or timeout error if polling expires.
    private func pollForConfirmation(uuid: String) async throws {
        let pollingIntervalSeconds: UInt64 = 2_500_000_000 // 2.5 seconds
        let maxAttempts = 48 // 2 minutes at 2.5s per poll

        for attempt in 0..<maxAttempts {
            try Task.checkCancellation()

            do {
                let status = try await apiClient.request(.checkQRStatus(uuid: uuid))

                if status.confirmed, let accessToken = status.accessToken,
                   let refreshToken = status.refreshToken, let expiresAt = status.expiresAt {
                    let token = AuthToken(
                        accessToken: accessToken,
                        refreshToken: refreshToken,
                        expiresAt: expiresAt
                    )
                    try tokenStorage.save(token)
                    authStateManager?.transition(to: .authenticated)
                    return
                }
            } catch {
                // Continue polling on network errors, will eventually timeout
            }

            if attempt < maxAttempts - 1 {
                try await Task.sleep(nanoseconds: pollingIntervalSeconds)
            }
        }

        // Polling timed out
        authStateManager?.transition(to: .unauthenticated)
        throw APIError.serverError(408) // Request timeout
    }

    // MARK: - Token Refresh

    /// Refreshes the access token if it's expired.
    /// - Returns: The valid token (either existing if not expired or newly refreshed).
    /// - Throws: Error if refresh fails.
    public func refreshIfNeeded() async throws -> AuthToken? {
        guard let currentToken = tokenStorage.load() else {
            return nil
        }

        if !currentToken.isExpired {
            return currentToken
        }

        let response = try await apiClient.request(.refreshToken(refreshToken: currentToken.refreshToken))
        let newToken = AuthToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: response.expiresAt
        )
        try tokenStorage.save(newToken)
        return newToken
    }

    // MARK: - Authenticated Requests

    /// Makes an authenticated API request with automatic token refresh on 401.
    /// If the access token is expired, it will be refreshed before the request.
    /// If a 401 occurs after refresh, tokens are cleared and the user is logged out.
    /// - Parameter endpoint: The endpoint to request.
    /// - Returns: The decoded response.
    /// - Throws: Any error from the request or authentication failure.
    public func authenticatedRequest<T: Decodable>(_ endpoint: Endpoint<T>) async throws -> T {
        // Get a valid token (refresh if needed)
        guard let token = try await refreshIfNeeded() else {
            throw APIError.unauthorized
        }

        // Create an authenticated endpoint with authorization header
        var authenticatedEndpoint = endpoint
        authenticatedEndpoint.addAuthorizationHeader(token: token.accessToken)

        do {
            return try await apiClient.request(authenticatedEndpoint)
        } catch APIError.unauthorized {
            // 401 after refresh - clear tokens and logout
            tokenStorage.clear()
            authStateManager?.transition(to: .unauthenticated)
            throw APIError.unauthorized
        }
    }
}

public extension Endpoint {
    /// Adds Bearer authorization header to the endpoint.
    mutating func addAuthorizationHeader(token: String) {
        var headers = self.headers ?? [:]
        headers["Authorization"] = "Bearer \(token)"
        self.headers = headers
    }
}
