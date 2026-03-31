//
//  LiveStatsService.swift
//  DouyinLiveTV
//
//  Service for fetching live room statistics from the Douyin API.
//

import Foundation
import DouyinLiveTVDomain

public class LiveStatsService {
    private let apiClient: APIClient
    private let authService: AuthService

    public init(apiClient: APIClient, authService: AuthService) {
        self.apiClient = apiClient
        self.authService = authService
    }

    public func fetchStats(for roomId: String) async throws -> LiveStats {
        let endpoint = Endpoint.getLiveStats(roomId: roomId)
        return try await authService.authenticatedRequest(endpoint)
    }
}
