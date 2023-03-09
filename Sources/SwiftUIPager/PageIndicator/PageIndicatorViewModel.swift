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

    /// Offset that is applied to the dot collection
    @Published private(set) var offset: CGFloat = 0

    /// Total size of the dot collection. This can be larger that the actual page indicator
    @Published private(set) var collectionSize: CGSize = .zero

    /// Index of the selected dot/page
    @Published var index: Int = 0

    /// Total count of dots/pages
    @Published private(set) var count: Int

    /// The style options for the page indicator
    let style: PageIndicatorStyle

    private(set) var hasStartedDrag = false
    private(set) var rollTimer: Timer?
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    /// The Width that got proposed to the PageIndicator View
    private let width: CGFloat
    
    /// Offset that needs to be applied such that needs to be applied to the dot collection such that the leftmost dot is aligned with
    /// the left edge of the page indicator
    var baseOffset: CGFloat {
        guard case let .constant(maxWidth) = self.style.width else {
            return 0
        }
        
        if self.collectionSize.width > maxWidth {
            return (self.collectionSize.width - maxWidth) / 2
        } else {
            return 0
        }
    }

    /// Actual width of the indicator, taking into account the styling information as well as the proposed size
    var indicatorWidth: CGFloat {
        if case let .constant(maxWidth) = self.style.width {
            if maxWidth > self.width {
                return self.width
            } else {
                return maxWidth
            }
        } else {
            if self.collectionSize.width > self.width {
                return self.width
            } else {
                return self.collectionSize.width
            }
        }
    }

    /// Width of a segment. A segment is defined by the width of a dot + the spacing between two dots.
    var segmentWidth: CGFloat {
        self.style.plain.shape.width + self.style.spacing
    }

    /// Create PageIndicatorViewModel
    ///
    /// - Parameter width: Width that was proposed to the PageIndicatorView upon initialization
    init(
        initialCount: Int = 0,
        style: PageIndicatorStyle,
        width: CGFloat,
        scheduler: AnySchedulerOf<DispatchQueue> = AnyScheduler.main
    ) {
        self.count = initialCount
        self.style = style
        self.width = width
        self.scheduler = scheduler
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
        if self.collectionSize.width > self.indicatorWidth {
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
                    self?.index = index
                }
            }
        }
    }

    /// Bearbeitet das Endevent der Drag Geste
    func handleDragEnding() {
        // Unset that drag has started
        self.hasStartedDrag = false
        self.stopRoll()
    }

    /// Setzt die Größe der Kollektion von Punkten
    func setCollectionSize(size: CGSize) {
        self.collectionSize = size
    }

    /// Setzt den aktuell ausgewählten Index
    func setIndex(_ index: Int) {
        guard index >= 0 && index < self.count else { return }
        withAnimation {
            self.index = index
        }
    }

    /// Setzt die Gesamtanzahl der Punkte des PageIndicator
    func setCount(_ count: Int) {
        self.count = count
    }

    /// Calculates the index of the dot that is focused by the given offset
    ///
    /// - Parameter hOffset: Offset within ``self.indicatorWidth``
    /// - Returns: Index of the focused dot or nil if space between dots is focused
    private func calcIndexForOffset(hOffset: CGFloat) -> Int? {
        if hOffset >= 0 && hOffset <= self.indicatorWidth {
            // Determine segment
            let segment = Int(hOffset - self.offset) / Int(self.segmentWidth)

            // Determine position within segment
            let pos = hOffset - (CGFloat(segment) * self.segmentWidth)

            if pos < self.style.plain.shape.width {
                return segment > self.count - 1 ? self.count - 1 : segment
            } else {
                return nil
            }
        } else if hOffset < 0 {
            return self.calcIndexForOffset(hOffset: 0)
        } else if hOffset > self.indicatorWidth {
            return self.calcIndexForOffset(hOffset: self.indicatorWidth)
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
        } else if hOffset > self.indicatorWidth {
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
                    var newOffset = self.offset + slice

                    if newOffset > 0 {
                        newOffset = 0
                    }

                    return newOffset
                case .behindEnd:
                    var newOffset = self.offset - slice

                    if newOffset < self.indicatorWidth - self.collectionSize.width {
                        newOffset = self.indicatorWidth - self.collectionSize.width
                    }

                    return newOffset
                }
            }()

            // Dispatch UI changes to main thread
            self.scheduler.schedule { [weak self] in
                self?.offset = newOffset
            }
            
            // Determine the index that is focused by the drag gesture
            let hOffset = {
                switch focusedArea {
                case .beforeStart:
                    return CGFloat(0)
                case .behindEnd:
                    return self.indicatorWidth
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
