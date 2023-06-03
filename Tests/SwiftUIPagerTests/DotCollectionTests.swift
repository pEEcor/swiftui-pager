//
//  DotCollectionTests.swift
//
//  Copyright © 2023 Paavo Becker.
//

import XCTest

@testable import SwiftUIPager

final class DotCollectionTests: XCTestCase {
    func test_init_shouldSetZeroSizedWindow() {
        let sut = self.makeSUT()

        XCTAssertEqual(sut.window.width, 0)
        XCTAssertEqual(sut.window.offset, 0)
    }

    func test_init_shouldSelectFirstDotWhenCountIsLargerThanZero() {
        let sut = self.makeSUT(count: 1)

        XCTAssertNotNil(sut.selectedIndex)
        XCTAssertEqual(sut.selectedIndex!, 0)
    }

    func test_count_shouldReturnTheCountOfDots() {
        let count = 5
        let sut = self.makeSUT(count: count)

        XCTAssertEqual(sut.count, count)
    }

    func test_selectedIndex_ShouldReturnNilWhenCountIsLessThanOne() {
        let sut = self.makeSUT(count: 0)

        XCTAssertNil(sut.selectedIndex)
    }

    func test_selectedIndex_ShouldReturnTheSelectedIndexIfCountIsLargerThanZero() {
        let sut = self.makeSUT(count: 1)

        XCTAssertNotNil(sut.selectedIndex)
        XCTAssertEqual(sut.selectedIndex!, 0)
    }

    func test_width_shouldReturnZeroForEmptyDotCollection() {
        let sut = self.makeSUT(count: 0)

        XCTAssertEqual(sut.width, 0)
    }

    func test_width_shouldReturnWidthOfHighlightStyleForDotCollectionWithOneElement() {
        let style = IndicatorStyle(
            focusedStyle: .circle(radius: 1)
        )
        let sut = self.makeSUT(count: 1, style: style)

        XCTAssertEqual(sut.width, 1)
    }

    /// Given: Dot Collection with n Elements
    /// Then: Width should be 1 `width of focused Style`
    ///                     + (n - 1) * `width of plain style`
    ///                     + (n - 1) * `spacing`
    func test_width_shouldReturnCorrectWidth() {
        let n = Int.random(in: 2 ..< 50)
        let focusedWidth = 3.0
        let plainWidth = 2.0
        let spacing = 1.0
        let style = IndicatorStyle(
            plainStyle: .circle(radius: plainWidth),
            focusedStyle: .circle(radius: focusedWidth),
            spacing: spacing
        )
        let sut = self.makeSUT(count: n, style: style)

        XCTAssertEqual(
            sut.width,
            focusedWidth + Double(n - 1) * plainWidth + Double(n - 1) * spacing
        )
    }

    func test_height_shouldReturnZeroWhenDotCollectionIsEmpty() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        let sut = self.makeSUT(count: 0, style: style)

        XCTAssertEqual(sut.height, 0)
    }

    func test_height_shouldReturnFocusedHeightWhenDotCollectionHasExactlyOneElement() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 3),
            focusedStyle: .circle(radius: 2),
            spacing: 1
        )
        let sut = self.makeSUT(count: 1, style: style)

        XCTAssertEqual(sut.height, 2)
    }

    func test_height_shouldReturnLargestHeightWhenDotCollectionHasMoreThanOneElement() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 3),
            focusedStyle: .circle(radius: 2),
            spacing: 1
        )
        let sut = self.makeSUT(count: 2, style: style)

        XCTAssertEqual(sut.height, 3)
    }

    func test_subscript_shouldReturnNilWhenIndexIsOutOfBounds() {
        let sut = self.makeSUT(count: 5)

        XCTAssertNil(sut[-1])
        XCTAssertNil(sut[5])
    }

    func test_subscript_shouldReturnDotWhenIndexIsInBounds() {
        let sut = self.makeSUT(count: 5)

        XCTAssertNotNil(sut[0])
    }

    func test_getOffset_ShouldReturnNilWhenDotDoesNotExist() {
        let sut = self.makeSUT(count: 0)
        let dot = Dot(isSelected: false, style: .default)

        XCTAssertNil(sut.getOffset(to: dot))
    }

    /// Given: Dot Collection with n Elements
    /// When: Random Element with index i gets selected
    /// Then: Offset should be i * (plain width)
    func test_getOffset_ShouldReturnOffset() {
        let n = Int.random(in: 2 ... 50)
        let i = Int.random(in: 1 ..< n)
        let focusedWidth = 3.0
        let plainWidth = 2.0
        let spacing = 1.0
        let style = IndicatorStyle(
            plainStyle: .circle(radius: plainWidth),
            focusedStyle: .circle(radius: focusedWidth),
            spacing: spacing
        )
        var sut = self.makeSUT(count: n, style: style)
        sut.select(sut[i]!)

        XCTAssertEqual(sut.getOffset(to: sut.selectedDot!), Double(i) * (plainWidth + spacing))
    }

    func test_isSelectedDotVisible_ShouldReturnTrueIfSelectedDotIsFullyVisible() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        let sut = self.makeSUT(count: 1, style: style)

        let result = sut.isVisible(dot: sut[0]!, inside: Window(offset: 0, width: 3))

        XCTAssertTrue(result)
    }

    func test_isSelectedDotVisible_shouldReturnFalseIfSelectedDotIsNotFullyVisible() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        let sut = self.makeSUT(count: 1, style: style)

        let result = sut.isVisible(dot: sut[0]!, inside: Window(offset: 0, width: 2))

        XCTAssertFalse(result)
    }

    func test_isVisible_shouldReturnFalseIfDotCollectionIsEmpty() {
        let sut = self.makeSUT(count: 0)
        let dot = Dot(isSelected: false, style: .default)

        let result = sut.isVisible(dot: dot, inside: Window(offset: 0, width: 2))

        XCTAssertFalse(result)
    }

    func test_isVisible_shouldReturnFalseWhenDotIsNotContainedInDotCollection() {
        let sut = self.makeSUT(count: 5)
        let dot = Dot(isSelected: false, style: .default)

        let result = sut.isVisible(dot: dot, inside: Window(offset: 0, width: 2))

        XCTAssertFalse(result)
    }

    func test_selectDot_shouldNotChangeSelectionWhenDotDoesNotExist() {
        var sut = self.makeSUT(count: 5)
        let dot = Dot(isSelected: false, style: .default)

        sut.select(dot)
        XCTAssertTrue(sut[0]!.isSelected)
    }

    func test_selectDot_shouldSelectDot() {
        var sut = self.makeSUT(count: 5)

        sut.select(sut[4]!)

        XCTAssertFalse(sut[0]!.isSelected)
        XCTAssertTrue(sut[4]!.isSelected)
    }

    func test_selectDot_shouldMoveWindowWhenSelectedIndexIsNotVisible() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        var sut = self.makeSUT(count: 5, style: style)
        sut.setWindowWidth(to: 3)

        sut.select(sut[1]!)

        XCTAssertEqual(sut.window.offset, 3)
    }

    func test_getLocationOf_shouldReturnNilWhenDotIsInBoundsOfWindow() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        var sut = self.makeSUT(count: 5, style: style)
        sut.setWindowWidth(to: 3)

        let location = sut.getLocation(of: sut[0]!)
        XCTAssertNil(location)
    }

    func test_getLocationOf_shouldReturnBeforeStartWhenIndexIsOnTheLeadingSideOfTheWindow() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        var sut = self.makeSUT(count: 5, style: style)
        sut.setWindowWidth(to: 3)
        sut.setWindowOffset(to: 3)

        let location = sut.getLocation(of: sut[0]!)
        XCTAssertEqual(location, .some(.beforeStart))
    }

    func test_getLocationOf_shouldReturnBehindEndWhenIndexIsOnTheTrailingSideOfTheWindow() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        var sut = self.makeSUT(count: 5, style: style)
        sut.setWindowWidth(to: 3)

        let location = sut.getLocation(of: sut[4]!)
        XCTAssertEqual(location, .some(.behindEnd))
    }

    func test_selectDot_shouldNotChangeSelectionWhenOffsetIsOutOfBounds() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        var sut = self.makeSUT(count: 5, style: style)

        sut.select(at: 15.1)
        XCTAssertTrue(sut[0]!.isSelected)

        sut.select(at: -0.1)
        XCTAssertTrue(sut[0]!.isSelected)
    }

    func test_selectDot_shouldChangeWhenOffsetFocusesDot() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        var sut = self.makeSUT(count: 5, style: style)

        sut.select(at: 14.0)

        XCTAssertTrue(sut[4]!.isSelected)
    }

    func test_setWindowWidth_shouldSetWindowWidth() {
        let width = 10.0
        var sut = self.makeSUT(count: 5)

        sut.setWindowWidth(to: width)

        XCTAssertEqual(sut.window.width, width)
    }

    func test_setWindowOffset_shouldSetWindowOffset() {
        let offset = 10.0
        var sut = self.makeSUT(count: 5)

        sut.setWindowOffset(to: offset)

        XCTAssertEqual(sut.window.offset, offset)
    }

    func test_setWindowOffset_shouldNotChangeSelectionWhenCurrentSelectionIsNotInNewWindow() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        var sut = self.makeSUT(count: 5, style: style)
        sut.setWindowWidth(to: 3)

        sut.setWindowOffset(to: 4.0)

        XCTAssertTrue(sut[0]!.isSelected)
    }

    func test_getIndex_shouldReturnNilWhenOffsetIsOutOfScope() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        let sut = self.makeSUT(count: 2, style: style)

        let index1 = sut.getIndex(at: -0.1)
        XCTAssertNil(index1)

        let index2 = sut.getIndex(at: 6.1)
        XCTAssertNil(index2)
    }

    func test_getIndex_shouldReturnNilWhenDotCollectionIsEmpty() {
        let sut = self.makeSUT(count: 0)

        let index = sut.getIndex(at: 0.0)
        XCTAssertNil(index)
    }

    func test_getIndex_shouldReturnIndexWhenOffsetFocusesDot() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        let sut = self.makeSUT(count: 2, style: style)

        let index = sut.getIndex(at: 4.1)
        XCTAssertEqual(index, 1)
    }

    func test_getOffset_shouldReturnNilWhenDotDoesNotExistInDotCollection() {
        let sut = self.makeSUT(count: 5)
        let dot = Dot(isSelected: false, style: .default)

        let offset = sut.getOffset(to: dot)
        XCTAssertNil(offset)
    }

    func test_getOffset_shouldReturnOffset() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        let sut = self.makeSUT(count: 5, style: style)

        let offset = sut.getOffset(to: sut[1]!)

        XCTAssertEqual(offset, 4)
    }

    func test_getOffset_shouldIncludeTheLastDotsWidthWhenSpecified() {
        let style = IndicatorStyle(
            plainStyle: .circle(radius: 2),
            focusedStyle: .circle(radius: 3),
            spacing: 1
        )
        let sut = self.makeSUT(count: 5, style: style)

        let offset = sut.getOffset(to: sut[1]!, includeDotWidth: true)

        XCTAssertEqual(offset, 6.0)
    }

    func test_change_shouldAddDotsWhenCountIsLargerThanElementCountOfDotCollection() {
        var sut = self.makeSUT(count: 5)

        sut.change(count: 10)

        XCTAssertEqual(sut.count, 10)
        XCTAssertTrue(sut[0]!.isSelected)
    }

    func test_change_shouldRemoveDotsWhenCountIsSmallerThanElementCountOfDotCollection() {
        var sut = self.makeSUT(count: 5)

        sut.change(count: 3)

        XCTAssertEqual(sut.count, 3)
        XCTAssertTrue(sut[0]!.isSelected)
    }

    func test_change_shouldShouldSelectLastDotWhenSelectedDotGetsRemoved() {
        var sut = self.makeSUT(count: 5)
        sut.select(sut[4]!)

        sut.change(count: 3)

        XCTAssertEqual(sut.count, 3)
        XCTAssertTrue(sut[2]!.isSelected)
    }

    func test_change_shouldSelectFirstDotWhenDotCollectionWasEmpty() {
        var sut = self.makeSUT(count: 0)

        sut.change(count: 3)

        XCTAssertEqual(sut.count, 3)
        XCTAssertTrue(sut[0]!.isSelected)
    }

    private func makeSUT(
        count: Int = 10,
        style: IndicatorStyle = .default
    ) -> DotCollection {
        let sut = DotCollection(count: count, style: style)

        return sut
    }
}
