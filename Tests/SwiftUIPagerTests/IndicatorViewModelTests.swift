import XCTest
import CombineSchedulers

@testable import SwiftUIPager

final class PageIndicatorViewModelTests: XCTestCase {

    func test_setIndex_shouldSelectDotWithGivenIndex() {
        let sut = makeSUT(count: 10)
        
        // Execute
        sut.setIndex(3)
        
        // Assert
        XCTAssertTrue(sut.dots[3]!.isSelected)
        XCTAssertFalse(sut.dots[0]!.isSelected)
    }
    
    func test_setIndex_shouldPublishNewDotCollection() {
        let sut = makeSUT(count: 10)
        
        let expectation = expectation(description: "wait for publisher")
        
        let _ = sut.$dots.first().sink { dots in
            expectation.fulfill()
        }
        
        // Execute
        sut.setIndex(3)
        
        // Assert
        wait(for: [expectation], timeout: 10)
    }
    
//    func test_setWidth_whereDotCollectionIsLargerThanProposedWidth() {
//        let sut = makeSUT(
//            count: 10,
//            style: PageIndicatorStyle(
//                plainStyle: .default,
//                focusedStyle: .default,
//                spacing: 10
//            )
//        )
//
//        // Execute
//        sut.setWidth(100)
//
//        // Assert
//        XCTAssertEqual(sut.window.width, 100)
//    }
//
//    func test_setWidth_whereDotCollectionIsSmallerThanProposedWidth() {
//        let sut = makeSUT(
//            count: 10,
//            style: PageIndicatorStyle(
//                plainStyle: .default,
//                focusedStyle: .default,
//                spacing: 10
//            )
//        )
//
//        // Execute
//        sut.setWidth(300)
//
//        // Assert
//        XCTAssertEqual(sut.window.width, 190)
//    }
    
    private func makeSUT(
        count: Int = 10,
        style: IndicatorStyle = .default,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> IndicatorViewModel {
        let sut = IndicatorViewModel(
            count: count,
            style: style,
            scheduler: scheduler
        )
        
        return sut
    }
}
