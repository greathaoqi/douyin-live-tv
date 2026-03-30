//
//  ContentView.swift
//  DouyinLiveTV
//
//  Root content view with conditional routing based on authentication state.
//  Shows LoginView when unauthenticated, main UI when authenticated.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var authStateManager: AuthStateManager

    init(authStateManager: AuthStateManager = DependencyContainer.shared.authStateManager) {
        self.authStateManager = authStateManager
    }

    var body: some View {
        Group {
            switch authStateManager.state {
            case .unauthenticated, .authenticating:
                loginView
            case .authenticated:
                mainUI
            }
        }
        .background(Color.systemBackground)
    }
}

private extension ContentView {
    var loginView: some View {
        let viewModel = LoginViewModel(
            authService: DependencyContainer.shared.authService,
            authStateManager: DependencyContainer.shared.authStateManager
        )
        return LoginView(viewModel: viewModel)
    }

    var mainUI: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.green)
            Text("Authenticated")
                .font(.system(size: 60, weight: .bold))
            Text("Welcome to Douyin Live TV")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
