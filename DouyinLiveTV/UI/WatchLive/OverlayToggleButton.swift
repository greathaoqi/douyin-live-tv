//
//  OverlayToggleButton.swift
//  DouyinLiveTV
//
//  Focusable toggle button to show/hide the statistics overlay.
//  Meets tvOS HIG minimum 88pt focus size requirement (LIVE-06).
//

import SwiftUI

public struct OverlayToggleButton: View {
    private let action: () -> Void
    private let showingOverlay: Bool

    public init(showingOverlay: Bool, action: @escaping () -> Void) {
        self.showingOverlay = showingOverlay
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: showingOverlay ? "rectangle.slash" : "square.rectangle.stack")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(16)
        }
        .frame(minWidth: 88, minHeight: 88) // tvOS HIG minimum focus size (LIVE-06)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .focusable()
        .focusEffect()
    }
}

// Preview support
#Preview {
    VStack(spacing: 32) {
        OverlayToggleButton(showingOverlay: true, action: {})
        OverlayToggleButton(showingOverlay: false, action: {})
    }
    .padding()
    .background(Color.black)
}
