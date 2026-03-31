import Foundation
import DouyinLiveTVDomain

public struct QRStatusResponse: Codable, Sendable {
    public let confirmed: Bool
    public let accessToken: String?
    public let refreshToken: String?
    public let expiresAt: Date?

    public init(
        confirmed: Bool,
        accessToken: String? = nil,
        refreshToken: String? = nil,
        expiresAt: Date? = nil
    ) {
        self.confirmed = confirmed
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    public var hasTokens: Bool {
        return accessToken != nil && refreshToken != nil && expiresAt != nil
    }
}

public extension Endpoint where Response == LoginQRCode {
    static func getQRCode(baseURL: URL = URL(string: "https://sso.douyin.com")!) -> Endpoint<LoginQRCode> {
        let headers = [
            "Accept": "application/json",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        return Endpoint<LoginQRCode>(
            baseURL: baseURL,
            path: "/get_qr_code",
            method: .get,
            parameters: nil,
            headers: headers,
            body: nil
        )
    }
}

public extension Endpoint where Response == QRStatusResponse {
    static func checkQRStatus(uuid: String, baseURL: URL = URL(string: "https://sso.douyin.com")!) -> Endpoint<QRStatusResponse> {
        let headers = [
            "Accept": "application/json",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        return Endpoint<QRStatusResponse>(
            baseURL: baseURL,
            path: "/check_qr_status",
            method: .get,
            parameters: ["uuid": uuid],
            headers: headers,
            body: nil
        )
    }
}

public struct RefreshTokenResponse: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: Date

    public init(
        accessToken: String,
        refreshToken: String,
        expiresAt: Date
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }
}

public extension Endpoint where Response == RefreshTokenResponse {
    static func refreshToken(
        refreshToken: String,
        baseURL: URL = URL(string: "https://sso.douyin.com")!
    ) -> Endpoint<RefreshTokenResponse> {
        let headers = [
            "Accept": "application/json",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        return Endpoint<RefreshTokenResponse>(
            baseURL: baseURL,
            path: "/refresh_token",
            method: .post,
            parameters: ["refresh_token": refreshToken],
            headers: headers,
            body: nil
        )
    }
}

public extension Endpoint where Response == LiveStats {
    static func getLiveStats(
        roomId: String,
        baseURL: URL = URL(string: "https://api.douyin.com")!
    ) -> Endpoint<LiveStats> {
        let headers = [
            "Accept": "application/json",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        return Endpoint<LiveStats>(
            baseURL: baseURL,
            path: "/live/room/stats",
            method: .get,
            parameters: ["room_id": roomId],
            headers: headers,
            body: nil
        )
    }
}
