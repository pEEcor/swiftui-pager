import XCTest

@testable import SwiftUIPager

final class DotCollectionTests: XCTestCase {
    func test_change_shouldAddDotsWhenCountIsIncreased() {
        var sut = makeSUT(count: 5)
        sut.selectDot(with: 2)
        
        // Execute
        sut.change(count: 10)
        
        // Assert count
        XCTAssertEqual(sut.count, 10)
        
        // Assert selection
        guard let index = sut.selectedIndex else {
            XCTFail("Expected index")
            return
        }
        XCTAssertEqual(index, 2)
    }
    
    func test_change_shouldRemoveDotsWhenCountIsIncreased() {
        var sut = makeSUT(count: 10)
        sut.selectDot(with: 7)
        
        // Execute
        sut.change(count: 5)
        
        // Assert count
        XCTAssertEqual(sut.count, 5)
        
        // Assert selection
        guard let index = sut.selectedIndex else {
            XCTFail("Expected index")
            return
        }
        XCTAssertEqual(index, 4)
    }
    
    func test_change_shouldSelectFirstWhenCollectionWasEmpty() {
        var sut = makeSUT(count: 0)
        
        // Execute
        sut.change(count: 2)
        
        // Assert selection
        guard let index = sut.selectedIndex else {
            XCTFail("Expected index")
            return
        }
        XCTAssertEqual(index, 0)
    }
    
    func test_change_shouldNotHaveSelectedDotWhenChangedToCountOfZero() {
        var sut = makeSUT(count: 10)
        
        // Execute
        sut.change(count: 0)
        
        // Assert
        XCTAssertNil(sut.selectedIndex)
    }
    
    func test_init_shouldSetSelectedDotToFirstDotWhenCountNotZero() {
        let sut = makeSUT(count: 10)
        
        // Assert
        guard let index = sut.selectedIndex else {
            XCTFail("Expected index")
            return
        }
        XCTAssertEqual(index, 0)
    }
    
    func test_subscript_shouldReturnNilWhenIndexOutOfRange() {
        let sut = makeSUT(count: 10)
        
        // Assert
        XCTAssertNil(sut[-1])
        XCTAssertNil(sut[10])
    }
    
    func test_subscript_shouldReturnDotWhenIndexInRange() {
        let sut = makeSUT(count: 10)
        
        XCTAssertNotNil(sut[0])
        XCTAssertNotNil(sut[9])
    }
    
    func test_select_shouldChangeIndex() {
        var sut = makeSUT(count: 10)
        
        // Execute
        sut.selectDot(with: 2)
        
        // Assert
        XCTAssertTrue(sut[2]!.isSelected)
    }
    
    func test_select_shouldChangeSelectionToExactlyOneDot() {
        var sut = makeSUT(count: 10)
        
        // Execute
        sut.selectDot(with: 5)
        
        // Assert
        XCTAssertEqual(sut.filter({ $0.isSelected }).count, 1)
    }
    
    func test_getOffsetToSelectedDot() {
        var sut = makeSUT(
            count: 10,
            style: PageIndicatorStyle(
                plainStyle: .rect(size: CGSize(width: 10, height: 10)),
                focusedStyle: .default,
                spacing: 10
            )
        )
        
        // Assert: Should return 0 when selected dot is 0
        let offset1 = sut.getOffsetToSelectedDot()
        XCTAssertEqual(offset1, 0)
        
        
        // Assert: Should return 20 when selected dot is 1
        sut.selectDot(with: 1)
        let offset2 = sut.getOffsetToSelectedDot()
        XCTAssertEqual(offset2, 20)
    }
    
    func test_isSelectedDotVisible() {
        var sut = makeSUT(
            count: 0,
            style: PageIndicatorStyle(
                plainStyle: .rect(size: CGSize(width: 10, height: 10)),
                focusedStyle: .default,
                spacing: 10
            )
        )
        
        // Assert: Collection with no selection should return false
        XCTAssertFalse(sut.isSelectedDotVisible(in: Window(offset: 0, width: 100)))
        
        // Assert: Collection with dots should return true if dot is visible
        sut.change(count: 10)
        XCTAssertTrue(sut.isSelectedDotVisible(in: Window(offset: 0, width: 100)))
        
        // Assert: Collection with dots should return false if dot is not visible
        XCTAssertFalse(sut.isSelectedDotVisible(in: Window(offset: 1, width: 100)))
        
        // Assert: Collection with dots should return false if dot is not visible
        sut.selectDot(with: 3)
        XCTAssertFalse(sut.isSelectedDotVisible(in: Window(offset: 61, width: 100)))
    }
    
    private func makeSUT(
        count: Int = 10,
        style: PageIndicatorStyle = .default
    ) -> DotCollection {
        let sut = DotCollection(count: count, style: style)
        
        return sut
    }
}
