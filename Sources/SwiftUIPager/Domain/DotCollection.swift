//
//  DotCollection.swift
//
//  Copyright © 2023 Paavo Becker.
//

import Foundation

// MARK: - Edge

enum Edge {
    case leading
    case trailing
}

// MARK: - DotCollection

/// A Collection that holds a dot model for each dot in the page indicator
struct DotCollection: Sendable {
    /// Typealias for index of dots
    typealias Index = Int

    /// The amount of dots in the collection
    var count: Int {
        self.dots.count
    }

    /// The index of the selected dot
    var selectedIndex: Index? {
        self.dots.firstIndex(where: { $0.isSelected })
    }

    /// The width of the dot collection
    var width: Double {
        // Calculate width of all dots
        let dotsWidth = self.dots.reduce(0) { partialResult, dot in
            partialResult + dot.width
        }

        // Add spacings between dots
        if self.dots.count > 1 {
            return dotsWidth + Double(self.dots.count - 1) * self.style.spacing
        } else {
            return dotsWidth
        }
    }

    /// The height of the dot collection
    var height: Double {
        return max(self.style.focused.shape.height, self.style.plain.shape.height)
    }

    /// The window over the dots that is currently visible
    private(set) var window: Window

    private var dots: [Dot]
    private let style: IndicatorStyle

    init(
        count: Int,
        style: IndicatorStyle
    ) {
        self.style = style
        self.dots = Array(
            repeating: Dot(
                isSelected: false,
                style: style
            ),
            count: count
        )
        self.window = Window(offset: .zero, width: .zero)

        if !self.dots.isEmpty {
            self.dots[0].select()
        }
    }

    subscript(index: Index) -> Dot? {
        guard index >= 0 && index < self.dots.count else {
            return nil
        }

        return self.dots[index]
    }

    func filter(_ isIncluded: (Dot) throws -> Bool) rethrows -> [Dot] {
        try self.dots.filter(isIncluded)
    }

    /// Calculates the offset to the selected dot respecting the styling of all preceding dots
    /// - Returns: Offset to selected dot
    func getOffsetToSelectedDot(
        includeWidth: Bool = false
    ) -> Double? {
        guard let selectedDot = self.dots.first(where: { $0.isSelected }) else {
            return nil
        }

        let prefixDots = self.dots
            .prefix(while: { !$0.isSelected })

        let offset = prefixDots
            .reduce(CGFloat(0)) { partialResult, dot in
                partialResult + dot.width + self.style.spacing
            }

        return offset + (includeWidth ? selectedDot.width : 0)
    }

    /// Returns true if selected dot is fully visibile inside the given window
    /// - Parameter window: The window that describes the visible section of the page indicator
    /// dot collection
    /// - Returns: true if a dot is selected and is fully visible, otherwise false
    func isSelectedDotVisible(
        in window: Window
    ) -> Bool {
        guard let min: Double = self.getOffsetToSelectedDot() else {
            return false
        }

        guard let max: Double = self.getOffsetToSelectedDot(includeWidth: true) else {
            return false
        }

        return min >= window.min && max <= window.max
    }

    /// Selects the dot with the given index
    ///
    /// If the given index is part of the collection of dots, then the dot with the given index
    /// gets selected and the current selection gets canceled. The selections stays unchanged if
    /// the index is not part of the collection.
    /// - Parameter index: Index of the dot that should be selected
    mutating func selectDot(with index: Index) {
        // Abort if index is invalid
        guard index >= 0 && index < self.dots.count else {
            return
        }

        // Deselect current dot
        if let currentIndex = self.dots.firstIndex(where: { $0.isSelected }) {
            self.dots[currentIndex].deselect()
        }

        // Select dot with given index
        self.dots[index].select()

        if !self.isSelectedDotVisible(in: self.window) {
            switch self.getLocationOf(index: index) {
            case .some(.beforeStart):
                guard let leadingOffset = self.offset(of: index) else {
                    return
                }

                self.window.setOffset(to: leadingOffset)
            case .some(.behindEnd):
                guard let trailingOffset = self.offset(of: index, includeDotWidth: true) else {
                    return
                }

                self.window.setOffset(to: trailingOffset - self.window.width)
            case .none:
                return
            }
        }
    }

    private func getLocationOf(index: Index) -> FocusedLocation? {
        guard let leadingOffset = self.offset(of: index) else {
            return nil
        }

        guard let trailingOffset = self.offset(of: index, includeDotWidth: true) else {
            return nil
        }

        if leadingOffset - self.window.offset <= 0 {
            return .beforeStart
        } else if self.window.width + self.window.offset - trailingOffset <= 0 {
            return .behindEnd
        } else {
            return nil
        }
    }

    /// Selects the dot at the given index
    /// - Parameter offset: Offset inside collection
    mutating func selectDot(with offset: Double) {
        guard let index = self.index(at: offset) else {
            return
        }

        self.selectDot(with: index)
    }

    mutating func setWindowWidth(to width: Double) {
        self.window.setWidth(to: width)
    }

    mutating func setWindowOffset(to offset: Double) {
        self.window.setOffset(to: offset)
    }

    /// Given an offset inside the dot collection, this method returns the index of the focused dot
    ///
    /// If the offset targets a gap between dots, nil is returned.
    /// - Parameter offset: The offset to get the index for
    /// - Returns: Index if dot is focused, otherwise nil
    func index(at offset: Double) -> Index? {
        // Ensure that offset is not outside of dot collection
        guard offset > 0 && offset < self.width else {
            return nil
        }

        // Ensure that dot collection is not empty
        guard !self.dots.isEmpty else {
            return nil
        }

        var tmp: Double = 0

        for (index, dot) in self.dots.enumerated() {
            let x1 = tmp
            let x2 = tmp + dot.width

            if offset > x1 && offset < x2 {
                return index
            }

            tmp = x2 + self.style.spacing
        }

        return nil
    }

    func offset(of index: Index, includeDotWidth: Bool = false) -> Double? {
        // Ensure that index exists
        guard index >= 0 && index < self.dots.count else {
            return nil
        }

        var offset: Double = 0

        for (i, dot) in self.dots.enumerated() {
            if index == i {
                return includeDotWidth ? offset + dot.width : offset
            } else {
                offset += dot.width + self.style.spacing
            }
        }

        return nil
    }

    mutating func change(count: Int) {
        if count < self.dots.count {
            // Remove excess dots
            self.dots.removeLast(self.dots.count - count)

            // Check if there is a selected dot. If not, select last element
            if !self.dots.contains(where: \.isSelected) {
                self.selectDot(with: self.dots.endIndex - 1)
            }
        } else if count > self.dots.count && self.dots.count == 0 {
            // Append dots
            self.append(count: count)

            // Select first dot because no dot was selected
            self.dots[0].select()
        } else if count > self.dots.count {
            // Append dots
            self.append(count: count)
        }
    }

    private mutating func append(count: Int) {
        // Create additional dots
        let dots = Array(
            repeating: Dot(
                isSelected: false,
                style: self.style
            ),
            count: count - self.dots.count
        )

        // Append additional dots
        self.dots.append(contentsOf: dots)
    }
}
