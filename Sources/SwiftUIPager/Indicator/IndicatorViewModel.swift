//
//  IndicatorViewModel.swift
//
//  Copyright © 2023 Paavo Becker.
//

import Combine
import CombineSchedulers
import SwiftUI

// MARK: - IndicatorViewModel

class IndicatorViewModel: ObservableObject, @unchecked Sendable {
    /// Rate that is used to automatically roll the dot collection
    static let ROLL_UPDATE_RATE = Double(1) / Double(120)

    /// Distance that is rolled per roll frame
    static let ROLL_DISTANCE_FACTOR = Double(20)

    /// Representation of all dots of the indicator
    @Published
    private(set) var dots: DotCollection

    /// The style options for the page indicator
    @Published
    private(set) var style: IndicatorStyle

    private(set) var hasStartedDrag = false
    private(set) var rollTimer: Timer?

    private let scheduler: AnySchedulerOf<DispatchQueue>

    /// Creates PageIndicatorViewModel
    ///
    /// - Parameters:
    ///   - count: The initail count of page indicator dots
    ///   - style: The initial style definition for the page indicator
    ///   - scheduler: A scheduler used to perform the automated scrolling when scrubbing
    init(
        count: Int = 0,
        style: IndicatorStyle = .default,
        scheduler: AnySchedulerOf<DispatchQueue> = AnyScheduler.main
    ) {
        self.style = style
        self.scheduler = scheduler

        self.dots = DotCollection(count: count, style: style)
    }

    /// Handles a Drag Gesture
    /// - Parameters:
    ///   - startLocation: Start location of the drag gesture
    ///   - translation: Translation relative to start location
    func handleTranslation(
        startLocation: CGPoint,
        translation: CGSize
    ) {
        self.hasStartedDrag = true

        // The targeted offset inside the page indicator window
        let offset = startLocation.x + translation.width

        // If PageIndicatorView is smaller than collection size, roll when drag gesture focuses
        // area outside of the indicator
        if let focusedArea = self.calcFocusedLocation(offset: offset) {
            if self.dots.width > self.dots.window.width {
                self.roll(focusedLocation: focusedArea)
            } else {
                self.stopRoll()
            }
        } else {
            if self.rollTimer != nil {
                self.stopRoll()
            }
            withAnimation {
                self.dots.select(at: offset + self.dots.window.offset)
            }
        }
    }

    /// Handles end of drag Gesture
    func handleDragEnding() {
        // Unset that drag has started
        self.hasStartedDrag = false
        self.stopRoll()
    }

    /// Sets the current index
    func setIndex(_ index: Int) {
        guard let dot = self.dots[index] else {
            return
        }

        withAnimation {
            self.dots.select(dot)
        }
    }

    /// Sets the total count of pages/dots
    func setCount(_ count: Int) {
        self.dots.change(count: count)
    }

    /// Sets a new style
    /// - Parameter style: The new style
    func setStyle(_ style: IndicatorStyle) {
        self.style = style
    }

    /// Sets the width that is proposed by the enclosing view
    /// - Parameter width: The available width for the page indicator view
    func setWidth(_ width: Double) {
        let width = self.calcIndicatorWidth(from: width)

        // Set new Window
        self.dots.setWindowWidth(to: width)
    }

    /// Calculates the actual page indicator width
    ///
    /// - Returns: Actual page indicator width
    private func calcIndicatorWidth(from proposedWidth: Double) -> Double {
        if self.dots.width > proposedWidth {
            return proposedWidth
        } else {
            return self.dots.width
        }
    }

    /// Calculates if area before indicator, the indicator itself or area behind the indicator is
    /// focused by the given offset
    ///
    /// - Parameter offset: Offset relative to the start location of the indicator (left border)
    /// - Returns: The focused area or nil if the indicator itself is focused
    private func calcFocusedLocation(offset: CGFloat) -> FocusedLocation? {
        if offset < 0 {
            return .beforeStart
        } else if offset > self.dots.window.width {
            return .behindEnd
        } else {
            return nil
        }
    }

    /// Starts automated rolling of the window
    /// - Parameter focusedLocation: The area that is focused outside of the indicator
    private func roll(focusedLocation: FocusedLocation) {
        guard self.rollTimer == nil else {
            return
        }

        self.startRolling(focusedLocation: focusedLocation)
    }

    private func calcSlice(for focusedLocation: FocusedLocation) -> Double {
        let totalSlice = Self.ROLL_DISTANCE_FACTOR * self.style.plain.shape.width
        let slice = totalSlice * Self.ROLL_UPDATE_RATE

        switch focusedLocation {
        case .beforeStart:
            return -slice
        case .behindEnd:
            return slice
        }
    }

    private func startRolling(focusedLocation: FocusedLocation) {
        self.rollTimer = Timer.scheduledTimer(
            withTimeInterval: Self.ROLL_UPDATE_RATE,
            repeats: true
        ) { [weak self] _ in
            guard let dots = self?.dots else {
                return
            }

            if dots.window.offset < 0 || dots.window.offset > dots.width - dots.window.width {
                self?.stopRoll()
            }

            guard let movement = self?.calcSlice(for: focusedLocation) else {
                return
            }

            let targetOffset = movement + dots.window.offset

            let newOffset = {
                if targetOffset <= 0 {
                    return 0.0
                } else if targetOffset >= dots.width - dots.window.width {
                    return dots.width - dots.window.width
                } else {
                    return targetOffset
                }
            }()

            // Dispatch UI changes to main thread
            self?.scheduler.schedule { [weak self] in
                withAnimation {
                    self?.dots.setWindowOffset(to: newOffset)

                    if movement <= 0 {
                        self?.dots.select(at: dots.window.offset)
                    } else {
                        self?.dots.select(at: dots.window.offset + dots.window.width)
                    }
                }
            }
        }
    }

    /// Stops rolling of the dot collection
    private func stopRoll() {
        self.rollTimer?.invalidate()
        self.rollTimer = nil
    }
}
