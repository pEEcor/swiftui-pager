//
//  DotTests.swift
//
//  Copyright © 2023 Paavo Becker.
//

import XCTest

@testable import SwiftUIPager

final class DotTests: XCTestCase {
    func test_init_shouldSetWidthToFocusedWidthWhenFocused() {
        let style = IndicatorStyle.default
        let sut = self.makeSUT(isSelected: true)

        // Assert
        XCTAssertEqual(sut.width, style.focused.shape.width)
    }

    func test_init_shouldSetWidthToPlainWidthWhenNotFocused() {
        let style = IndicatorStyle.default
        let sut = self.makeSUT(isSelected: false)

        // Assert
        XCTAssertEqual(sut.width, style.plain.shape.width)
    }

    func test_select_shouldSelectDot() {
        let style = IndicatorStyle.default
        var sut = self.makeSUT(isSelected: false)

        // Execute
        sut.select()

        // Assert
        XCTAssertEqual(sut.width, style.focused.shape.width)
        XCTAssertTrue(sut.isSelected)
    }

    func test_deselect_shouldDeselectDot() {
        let style = IndicatorStyle.default
        var sut = self.makeSUT(isSelected: true)

        // Execute
        sut.deselect()

        // Assert
        XCTAssertEqual(sut.width, style.plain.shape.width)
        XCTAssertFalse(sut.isSelected)
    }

    private func makeSUT(
        isSelected: Bool = false,
        style: IndicatorStyle = .default
    ) -> Dot {
        let sut = Dot(isSelected: isSelected, style: style)

        return sut
    }
}
