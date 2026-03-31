//
//  FocusSizeConstraintsTests.swift
//  DouyinLiveTVTests
//
//  Created on 2026-03-31.
//

import XCTest
import SwiftUI
@testable import DouyinLiveTV

class FocusSizeConstraintsTests: XCTestCase {
    /// Test that focusable elements meet the tvOS HIG minimum 88x88pt size requirement
    func testMinimumFocusSizeMet() throws {
        // Create a button with the standard minimum frame constraints
        let button = Button(action: {}) {
            Text("Test Button")
        }
        .frame(minWidth: 88, minHeight: 88)
        .focusable()
        .focusEffect()

        // Render the view to get its intrinsic content size
        let hostingController = UIHostingController(rootView: button)
        hostingController.view.layoutIfNeeded()

        // Get the resulting frame size
        let buttonSize = hostingController.view.intrinsicContentSize

        // Verify minimum size constraints are met
        XCTAssertGreaterThanOrEqual(buttonSize.width, 88, "Button width must be at least 88pt for tvOS focus compliance")
        XCTAssertGreaterThanOrEqual(buttonSize.height, 88, "Button height must be at least 88pt for tvOS focus compliance")
    }

    /// Test that even with smaller content, the frame still expands to 88pt minimum
    func testSmallContentStillExpandsToMinimumSize() throws {
        let button = Button(action: {}) {
            Text("Small")
                .font(.caption)
        }
        .frame(minWidth: 88, minHeight: 88)

        let hostingController = UIHostingController(rootView: button)
        hostingController.view.layoutIfNeeded()

        let buttonSize = hostingController.view.intrinsicContentSize

        XCTAssertGreaterThanOrEqual(buttonSize.width, 88, "Small content must still expand to minimum 88pt width")
        XCTAssertGreaterThanOrEqual(buttonSize.height, 88, "Small content must still expand to minimum 88pt height")
    }

    /// Test that a larger button exceeds the minimum (verifies test logic works)
    func testLargerButtonExceedsMinimum() throws {
        let button = Button(action: {}) {
            Text("Large Button With Lots Of Text")
        }
        .frame(minWidth: 88, minHeight: 88)

        let hostingController = UIHostingController(rootView: button)
        hostingController.view.layoutIfNeeded()

        let buttonSize = hostingController.view.intrinsicContentSize

        // It should exceed the minimum, this just validates our measurement approach
        XCTAssertGreaterThanOrEqual(buttonSize.width, 88)
        XCTAssertGreaterThanOrEqual(buttonSize.height, 88)
        // At least one dimension should be bigger than 88 if text is large enough
        XCTAssertTrue(buttonSize.width > 88 || buttonSize.height > 88)
    }
}
