//
//  DotTests.swift
//  
//
//  Created by Paavo Becker on 31.03.23.
//

import XCTest

@testable import SwiftUIPager

final class DotTests: XCTestCase {
    func test_init_shouldSetWidthToFocusedWidthWhenFocused() {
        let style = PageIndicatorStyle.default
        let sut = makeSUT(isSelected: true)
        
        // Assert
        XCTAssertEqual(sut.width, style.focused.shape.width)
    }
    
    func test_init_shouldSetWidthToPlainWidthWhenNotFocused() {
        let style = PageIndicatorStyle.default
        let sut = makeSUT(isSelected: false)
        
        // Assert
        XCTAssertEqual(sut.width, style.plain.shape.width)
    }
    
    func test_select_shouldSelectDot() {
        let style = PageIndicatorStyle.default
        var sut = makeSUT(isSelected: false)
        
        // Execute
        sut.select()
        
        // Assert
        XCTAssertEqual(sut.width, style.focused.shape.width)
        XCTAssertTrue(sut.isSelected)
    }
    
    func test_deselect_shouldDeselectDot() {
        let style = PageIndicatorStyle.default
        var sut = makeSUT(isSelected: true)
        
        // Execute
        sut.deselect()
        
        // Assert
        XCTAssertEqual(sut.width, style.plain.shape.width)
        XCTAssertFalse(sut.isSelected)
    }
    
    private func makeSUT(
        isSelected: Bool = false,
        style: PageIndicatorStyle = .default
    ) -> Dot {
        let sut = Dot(isSelected: isSelected, style: style)
        
        return sut
    }

}
