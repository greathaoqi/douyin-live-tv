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

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func fetchStats(for roomId: String) async throws -> LiveStats {
        let endpoint = Endpoint.getLiveStats(roomId: roomId)
        return try await apiClient.request(endpoint)
    }
}
