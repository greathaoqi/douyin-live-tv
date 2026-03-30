//
//  AuthToken.swift
//  DouyinLiveTV
//
//  Codable model representing an authentication token from Douyin API
//

import Foundation

struct AuthToken: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    init(
        accessToken: String,
        refreshToken: String,
        expiresAt: Date
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    var isExpired: Bool {
        Date() >= expiresAt
    }
}
