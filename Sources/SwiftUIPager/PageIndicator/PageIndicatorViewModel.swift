import SwiftUI
import Combine
import CombineSchedulers

class PageIndicatorViewModel: ObservableObject {
    /// Location around Indicator that may be focused
    private enum FocusedArea {
        case beforeStart
        case behindEnd
    }

    /// Rate that is used to automatically roll the dot collection
    static var ROLL_UPDATE_RATE = Double(1) / Double(60)

    /// Distance that is rolled per roll frame
    static var ROLL_DISTANCE_FACTOR = Double(10)
    
    /// Representation of all dots of the indicator
    @Published private(set) var dots: DotCollection
    
    /// The window over the dots that is currently visible
    @Published private(set) var window: Window

    /// The style options for the page indicator
    @Published private(set) var style: PageIndicatorStyle

    private(set) var hasStartedDrag = false
    private(set) var rollTimer: Timer?
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    /// Offset that needs to be applied to the dot collection such that the leftmost dot is aligned
    /// with the left edge of the page indicator
    var baseOffset: CGFloat {
        (self.dots.width - self.window.width) / 2
    }

    /// Width of a segment. A segment is defined by the width of a dot + the spacing between two
    /// dots.
    var segmentWidth: CGFloat {
        self.style.plain.shape.width + self.style.spacing
    }

    /// Creates PageIndicatorViewModel
    ///
    /// - Parameters:
    ///   - count: The initail count of page indicator dots
    ///   - style: The initial style definition for the page indicator
    ///   - scheduler: A scheduler used to perform the automated scrolling when scrubbing
    init(
        count: Int = 0,
        style: PageIndicatorStyle = .default,
        scheduler: AnySchedulerOf<DispatchQueue> = AnyScheduler.main
    ) {
        self.style = style
        self.scheduler = scheduler
        
        self.dots = DotCollection(count: count, style: style)
        self.window = Window(offset: .zero, width: .zero)
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
        let hOffset = startLocation.x + translation.width

        // If PageIndicatorView is smaller than collection size, roll when drag gesture focuses
        // area outside of the indicator
        if self.dots.width > self.window.width {
            // Determine if drag currently focuses start or end area and perform roll
            let focusedArea = self.calcFocusedArea(hOffset: hOffset)
            
            if let focusedArea = focusedArea {
                self.roll(focusedArea: focusedArea)
            } else {
                self.stopRoll()
                self.selectIndexForOffset(hOffset: hOffset)
            }
        }
    }
    
    /// Selects the dot at the given offset
    /// - Parameter hOffset: Offset relative to start of indicator (left edge)
    func selectIndexForOffset(hOffset: CGFloat) {
        // Determine the index that is focused by the drag gesture
        let index = self.calcIndexForOffset(hOffset: hOffset)
        
        // If a dot is focused, select it
        if let index = index {
            // Dispatch UI changes to main thread
            self.scheduler.schedule { [weak self] in
                withAnimation {
                    self?.dots.select(index: index)
                }
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
        guard index >= 0 && index < self.dots.count else { return }
        
        // Get offset to make index visible
        
        withAnimation {
            self.dots.select(index: index)
        }
    }

    /// Sets the total count of pages/dots
    func setCount(_ count: Int) {
        self.dots.change(count: count)
    }
    
    /// Sets a new style
    /// - Parameter style: The new style
    func setStyle(_ style: PageIndicatorStyle) {
        self.style = style
    }
    
    /// Sets the width that is proposed by the enclosing view
    func setWidth(_ width: CGFloat) {
        let width = self.calcIndicatorWidth(from: width)
        
        // Set new Window
        self.window.setWidth(to: width)
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
    
    /// Calculates if the dot with the given index is visible
    /// - Parameter index: The index to check
    /// - Returns: True if dot of index is visible, otherwise false
    private func isVisible(index: Int) -> Bool {
        fatalError("Unimplemented")
    }

    /// Calculates the index of the dot that is focused by the given offset
    ///
    /// - Parameter hOffset: Offset within ``self.indicatorWidth``
    /// - Returns: Index of the focused dot or nil if space between dots is focused
    private func calcIndexForOffset(hOffset: CGFloat) -> Int? {
        if hOffset >= 0 && hOffset <= self.window.width {
            // Determine segment
            let segment = Int(hOffset - self.window.offset) / Int(self.segmentWidth)

            // Determine position within segment
            let pos = hOffset - (CGFloat(segment) * self.segmentWidth)

            if pos < self.style.plain.shape.width {
                return segment > self.dots.count - 1 ? self.dots.count - 1 : segment
            } else {
                return nil
            }
        } else if hOffset < 0 {
            return self.calcIndexForOffset(hOffset: 0)
        } else if hOffset > self.window.width {
            return self.calcIndexForOffset(hOffset: self.window.width)
        } else {
            return nil
        }
    }

    /// Calculates if area before indicator, the indicator itself or area behind the indicator is focused by the given offset
    ///
    /// - Parameter hOffset: Offset relative to the start location of the indicator (left border)
    /// - Returns: The focused area or nil if the indicator itself is focused
    private func calcFocusedArea(hOffset: CGFloat) -> FocusedArea? {
        if hOffset < 0 {
            return .beforeStart
        } else if hOffset > self.window.width {
            return .behindEnd
        } else {
            return nil
        }
    }

    /// Startet Rolling (automatisches Scrolling) der Kollektion von Punkten
    /// - Parameter focusedArea: Ort welcher fokusiert ist
    private func roll(focusedArea: FocusedArea) {
        guard self.rollTimer == nil else {
            return
        }

        self.rollTimer = Timer.scheduledTimer(
            withTimeInterval: Self.ROLL_UPDATE_RATE,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }

            let totalSlice = Self.ROLL_DISTANCE_FACTOR * self.segmentWidth
            let slice = totalSlice * Self.ROLL_UPDATE_RATE

            let newOffset = {
                switch focusedArea {
                case .beforeStart:
                    var newOffset = self.window.offset + slice

                    if newOffset > 0 {
                        newOffset = 0
                    }

                    return newOffset
                case .behindEnd:
                    var newOffset = self.window.offset - slice

                    if newOffset < self.window.width - self.dots.width {
                        newOffset = self.window.width - self.dots.width
                    }

                    return newOffset
                }
            }()

            // Dispatch UI changes to main thread
            self.scheduler.schedule { [weak self] in
                self?.window.setOffset(to: newOffset)
            }
            
            // Determine the index that is focused by the drag gesture
            let hOffset = {
                switch focusedArea {
                case .beforeStart:
                    return CGFloat(0)
                case .behindEnd:
                    return self.window.width
                }
            }()
            
            self.selectIndexForOffset(hOffset: hOffset)
        }
    }

    /// Stops rolling of the dot collection
    private func stopRoll() {
        self.rollTimer?.invalidate()
        self.rollTimer = nil
        
        
    }
}
