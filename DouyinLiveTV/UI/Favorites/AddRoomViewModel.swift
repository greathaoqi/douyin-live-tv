//
//  AddRoomViewModel.swift
//  DouyinLiveTV
//
//  View model for adding a new favorite room with URL parsing and API fetch.
//
//  Created on 2026-03-31.
//

import Foundation
import Observation
import DouyinLiveTVDomain

@Observable class AddRoomViewModel {
    let favoritesService: FavoritesService
    var inputText: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var addedRoom: LiveRoom? = nil

    init(favoritesService: FavoritesService = DependencyContainer.shared.favoritesService) {
        self.favoritesService = favoritesService
    }

    var isInputValid: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addRoom() async -> Bool {
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let roomId = favoritesService.extractRoomId(from: trimmedInput) else {
            errorMessage = "Could not extract room ID from input. Please enter a valid room ID or share URL."
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let room = try await favoritesService.addRoom(roomId: roomId)
            addedRoom = room
            isLoading = false
            return true
        } catch {
            errorMessage = "Could not find room. Please check the URL or ID and try again."
            isLoading = false
            return false
        }
    }
}
