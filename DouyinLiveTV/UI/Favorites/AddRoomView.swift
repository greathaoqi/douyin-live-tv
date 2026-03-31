//
//  AddRoomView.swift
//  DouyinLiveTV
//
//  View for adding a new favorite live room.
//
//  Created on 2026-03-31.
//

import SwiftUI

struct AddRoomView: View {
    @StateObject private var viewModel = AddRoomViewModel()
    @Binding var selectedTab: Tab

    var body: some View {
        VStack(spacing: 64) {
            Text("Add Live Room to Favorites")
                .font(.system(size: 28, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 16) {
                TextField("Enter room ID or URL", text: $viewModel.inputText)
                    .frame(minHeight: 88)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                    .background(Color.secondarySystemBackground)
                    .cornerRadius(8)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    Task {
                        let success = await viewModel.addRoom()
                        if success {
                            // Navigate to favorites tab after successful add
                            selectedTab = .favorites
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Add Room")
                            .font(.system(size: 24))
                    }
                    .frame(minHeight: 88)
                    .frame(maxWidth: .infinity)
                }
                .disabled(!viewModel.isInputValid || viewModel.isLoading)
                .focusable()
                .focusEffect()

                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.large)
                }
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemBackground)
        .onAppear {
            // Auto-focus on text field when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // tvOS automatically focuses the first focusable element
                // Additional focusing handled by system
            }
        }
        .onChange(of: viewModel.addedRoom) { _ in
            // When room is added successfully, switch to favorites
            if viewModel.addedRoom != nil {
                selectedTab = .favorites
            }
        }
    }
}

#Preview(traits: .defaultLayout) {
    AddRoomView(selectedTab: .constant(.addRoom))
}
