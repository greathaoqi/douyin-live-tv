//
//  TokenStorage.swift
//  DouyinLiveTV
//
//  Secure token storage using Keychain via KeychainSwift
//  Stores authentication tokens with .afterFirstUnlock accessibility for tvOS persistence
//

import Foundation
import KeychainSwift

public class TokenStorage {
    private let keychain: KeychainSwift

    private let accessTokenKey = "com.douyinlivetv.accessToken"
    private let refreshTokenKey = "com.douyinlivetv.refreshToken"
    private let expiresAtKey = "com.douyinlivetv.expiresAt"

    public init(keychain: KeychainSwift = KeychainSwift()) {
        self.keychain = keychain
        self.keychain.accessibility = .afterFirstUnlock
    }

    public func save(_ token: AuthToken) throws {
        keychain.set(token.accessToken, forKey: accessTokenKey, withAccessibility: .afterFirstUnlock)
        keychain.set(token.refreshToken, forKey: refreshTokenKey, withAccessibility: .afterFirstUnlock)

        let expiresAtString = ISO8601DateFormatter().string(from: token.expiresAt)
        keychain.set(expiresAtString, forKey: expiresAtKey, withAccessibility: .afterFirstUnlock)
    }

    public func load() -> AuthToken? {
        guard let accessToken = keychain.get(accessTokenKey),
              let refreshToken = keychain.get(refreshTokenKey),
              let expiresAtString = keychain.get(expiresAtKey),
              let expiresAt = ISO8601DateFormatter().date(from: expiresAtString) else {
            return nil
        }

        return AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }

    public func clear() {
        keychain.delete(accessTokenKey)
        keychain.delete(refreshTokenKey)
        keychain.delete(expiresAtKey)
    }

    public func hasValidTokens() -> Bool {
        guard let token = load() else {
            return false
        }
        return !token.isExpired
    }
}
