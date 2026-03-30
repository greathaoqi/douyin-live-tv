//
//  LoginView.swift
//  DouyinLiveTV
//
//  Login screen displaying QR code for Douyin authentication.
//  Follows tvOS HIG with 88x88pt minimum touch target size.
//

import SwiftUI
import UIKit

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @Environment(\.colorScheme) private var colorScheme

    init(viewModel: LoginViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center, spacing: 32) {
                        Spacer().frame(height: 64)

                        heading
                            .padding(.horizontal, 64)

                        Spacer().frame(height: 32)

                        qrCodeContainer
                            .frame(width: 280 + 32, height: 280 + 32)

                        instructions
                            .padding(.horizontal, 64)

                        Spacer().frame(height: 32)

                        startLoginButton
                            .frame(minWidth: 88, minHeight: 88)

                        if case .error(let message) = viewModel.state {
                            errorText(message)
                                .padding(.horizontal, 64)
                        }

                        if case .loading = viewModel.state {
                            loadingState
                                .padding(.horizontal, 64)
                        }

                        Spacer().frame(height: 64)
                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .background(Color.systemBackground)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Subviews

private extension LoginView {
    var heading: some View {
        Text("Douyin Live Login")
            .font(.system(size: 60, weight: .bold))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }

    var qrCodeContainer: some View {
        Group {
            if let qrImage = viewModel.qrImage {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280, height: 280)
                    .padding(16)
                    .background(Color.secondarySystemBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accentColor, lineWidth: 4)
                    )
            } else {
                Rectangle()
                    .fill(Color.secondarySystemBackground)
                    .frame(width: 280 + 32, height: 280 + 32)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accentColor, lineWidth: 4)
                    )
                    .overlay {
                        if viewModel.state == .idle {
                            Text("Tap Start Login to generate QR code")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else if viewModel.state == .loading {
                            ProgressView()
                                .tint(.accentColor)
                                .scaleEffect(2)
                        }
                    }
            }
        }
    }

    var instructions: some View {
        Text("Scan the QR code with your Douyin mobile app to log in.")
            .font(.system(size: 28, weight: .regular))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(3)
    }

    var startLoginButton: some View {
        Button(action: {
            Task {
                await viewModel.startLogin()
            }
        }) {
            Text("Start Login")
                .font(.system(size: 34, weight: .semibold))
                .frame(minWidth: 88, minHeight: 88)
                .padding(.horizontal, 32)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.state == .loading)
    }

    func errorText(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 28, weight: .regular))
            .foregroundColor(.systemRed)
            .multilineTextAlignment(.center)
    }

    var loadingState: some View {
        HStack(spacing: 16) {
            ProgressView()
                .tint(.accentColor)
            Text("Waiting for scan...")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Previews

#Preview(traits: .fixedLayout(width: 1920, height: 1080)) {
    let container = DependencyContainer.shared
    let vm = LoginViewModel(
        authService: container.authService,
        authStateManager: container.authStateManager
    )
    return LoginView(viewModel: vm)
}
