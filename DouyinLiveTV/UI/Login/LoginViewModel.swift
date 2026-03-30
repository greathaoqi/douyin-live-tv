//
//  LoginViewModel.swift
//  DouyinLiveTV
//
//  View model coordinating login UI with AuthService for QR login flow.
//

import Foundation
import Observation
import UIKit
import DouyinLiveTVDomain

@MainActor
@Observable
class LoginViewModel {
    var qrImage: UIImage?
    var state: ViewState = .idle

    var hasQR: Bool { qrImage != nil }

    private let authService: AuthService
    private let authStateManager: AuthStateManager

    enum ViewState: Equatable {
        case idle
        case loading
        case error(message: String)
    }

    init(authService: AuthService, authStateManager: AuthStateManager) {
        self.authService = authService
        self.authStateManager = authStateManager
    }

    func startLogin() async {
        state = .loading
        do {
            let qrCode = try await authService.startQRLogin()
            let qrSize = CGSize(width: 280, height: 280)
            qrImage = generateQRCode(from: qrCode.qrURL, size: qrSize)
            state = .idle
        } catch {
            if let apiError = error as? APIError {
                switch apiError {
                case .serverError(let code) where code == 408:
                    state = .error(message: "Your login session has expired. Please scan the QR code again to log in.")
                case .unauthorized:
                    state = .error(message: "Login process failed. Please generate a new QR code and try again.")
                default:
                    state = .error(message: "Could not connect to Douyin. Check your internet connection and try again.")
                }
            } else {
                state = .error(message: "Could not connect to Douyin. Check your internet connection and try again.")
            }
        }
    }
}
