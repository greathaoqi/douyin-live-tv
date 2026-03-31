//
//  TabItem.swift
//  DouyinLiveTV
//
//  Created on 2026-03-31.
//

import SwiftUI

enum Tab: Hashable {
    case watchLive
    case favorites
    case addRoom

    var title: String {
        switch self {
        case .watchLive:
            return "Watch Live"
        case .favorites:
            return "Favorites"
        case .addRoom:
            return "Add Room"
        }
    }

    var systemImage: String {
        switch self {
        case .watchLive:
            return "tv"
        case .favorites:
            return "star.fill"
        case .addRoom:
            return "plus"
        }
    }
}
