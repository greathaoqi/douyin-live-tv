//
//  LoginQRCode.swift
//  DouyinLiveTV
//
//  Codable model representing QR code response for login
//

import Foundation

struct LoginQRCode: Codable, Equatable {
    let uuid: String
    let qrURL: String
    let expiresAt: Date

    init(
        uuid: String,
        qrURL: String,
        expiresAt: Date
    ) {
        self.uuid = uuid
        self.qrURL = qrURL
        self.expiresAt = expiresAt
    }

    var isExpired: Bool {
        Date() >= expiresAt
    }
}
