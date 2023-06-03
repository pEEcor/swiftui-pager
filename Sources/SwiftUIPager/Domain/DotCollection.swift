//
//  DotCollection.swift
//
//  Copyright © 2023 Paavo Becker.
//

import Foundation

// MARK: - DotCollection

/// A Collection that manages multiple dots
struct DotCollection: Sendable {
    /// Typealias for index of dots
    typealias Index = Int

    /// The amount of dots in the collection
    var count: Int {
        self.dots.count
    }

    /// The index of the selected dot
    var selectedIndex: Index? {
        guard let selectedDot = self.selectedDot else {
            return nil
        }

        return self.getIndex(of: selectedDot)
    }

    /// The selected dot
    var selectedDot: Dot? {
        self.dots.first(where: { $0.isSelected })
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
        return self.dots.max { $0.height < $1.height }?.height ?? 0.0
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

        self.dots = (0 ..< count).map { _ in Dot(isSelected: false, style: style) }
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

    /// Returns true if selected dot is fully visibile inside the given window
    /// - Parameter dot: The dot that should be checked for visibility
    /// - Parameter window: The window that describes the visible section of the page indicator
    /// dot collection
    /// - Returns: true if a dot is selected and is fully visible, otherwise false
    func isVisible(
        dot: Dot,
        inside window: Window
    ) -> Bool {
        guard
            let min: Double = self.getOffset(to: dot),
            let max: Double = self.getOffset(to: dot, includeDotWidth: true) else
        {
            return false
        }

        return min >= window.min && max <= window.max
    }

    /// Selects the dot with the given index
    ///
    /// If the given index is part of the collection of dots, then the dot with the given index
    /// gets selected and the current selection gets canceled. The selections stays unchanged if
    /// the index is not part of the collection.
    /// - Parameter dot: The dot that should be selected
    mutating func select(_ dot: Dot) {
        // Abort if index is invalid
        guard let index = self.getIndex(of: dot) else {
            return
        }

        // Deselect current dot
        if let currentIndex = self.dots.firstIndex(where: { $0.isSelected }) {
            self.dots[currentIndex].deselect()
        }

        // Select dot with given index
        self.dots[index].select()

        let selectedDot = self.dots[index]

        if !self.isVisible(dot: selectedDot, inside: self.window) {
            switch self.getLocation(of: selectedDot) {
            case .some(.beforeStart):
                guard let leadingOffset = self.getOffset(to: selectedDot) else {
                    return
                }

                self.window.setOffset(to: leadingOffset)
            case .some(.behindEnd):
                guard let trailingOffset = self.getOffset(to: selectedDot, includeDotWidth: true) else {
                    return
                }

                self.window.setOffset(to: trailingOffset - self.window.width)
            case .none:
                return
            }
        }
    }

    /// Selects the dot at the given index
    /// - Parameter offset: Offset inside collection
    mutating func select(at offset: Double) {
        guard let index = self.getIndex(at: offset) else {
            return
        }

        self.select(self.dots[index])
    }

    /// Returns the location in relation to the active window
    /// - Parameter dot: The dot of interest
    /// - Returns: Returns location where the dot is located respective to the window
    func getLocation(of dot: Dot) -> FocusedLocation? {
        guard
            let leadingOffset = self.getOffset(to: dot),
            let trailingOffset = self.getOffset(to: dot, includeDotWidth: true) else
        {
            return nil
        }

        if leadingOffset - self.window.offset < 0 {
            return .beforeStart
        } else if self.window.width + self.window.offset - trailingOffset < 0 {
            return .behindEnd
        } else {
            return nil
        }
    }

    /// Sets the width of the window. The window defines the visible part of the dot collection
    /// - Parameter width: The width of the window
    mutating func setWindowWidth(to width: Double) {
        self.window.setWidth(to: width)
    }

    /// Sets the offset of the window relative to the dot collection
    /// - Parameter offset: the offset of the window
    mutating func setWindowOffset(to offset: Double) {
        self.window.setOffset(to: offset)
    }

    /// Given an offset inside the dot collection, this method returns the index of the focused dot
    ///
    /// If the offset targets a gap between dots, nil is returned.
    /// - Parameter offset: The offset to get the index for
    /// - Returns: Index if dot is focused, otherwise nil
    func getIndex(at offset: Double) -> Index? {
        // Ensure that dot collection is not empty
        guard !self.dots.isEmpty else {
            return nil
        }

        // Ensure that offset is not outside of dot collection
        guard offset >= 0 && offset <= self.width else {
            return nil
        }

        var tmp: Double = 0

        for (index, dot) in self.dots.enumerated() {
            let x1 = tmp
            let x2 = tmp + dot.width

            if offset >= x1 && offset <= x2 {
                return index
            }

            tmp = x2 + self.style.spacing
        }

        return nil
    }

    /// Returns the index of the given dot
    /// - Parameter dot: The dot to get the index for
    /// - Returns: The index of the given dot
    func getIndex(of dot: Dot) -> Index? {
        self.dots.firstIndex(where: { $0.id == dot.id })
    }

    /// Returns the offset of the given dot inside the dot collection. Returns nil if the dot is
    /// not contained in the collection or if the collection is empty
    /// - Parameters:
    ///   - dot: The dot to get the offset for
    ///   - includeDotWidth: When `false` the offset to the leading edge is returned, otherwise the
    ///   offset to the trailing edge. Defaults to `false`
    /// - Returns: Offset to leading or trailing edge of dot relative to dot collection
    func getOffset(
        to dot: Dot,
        includeDotWidth: Bool = false
    ) -> Double? {
        guard let index = self.dots.firstIndex(where: { $0.id == dot.id }) else {
            return nil
        }

        let prefix = self.dots.prefix(through: index).enumerated()

        let offset = prefix.reduce(0.0) { partialResult, tuple in
            let (i, dot) = tuple

            if index == i {
                return partialResult + (includeDotWidth ? dot.width : 0)
            } else {
                return partialResult + dot.width + self.style.spacing
            }
        }

        return offset
    }

    mutating func change(count: Int) {
        if count < self.dots.count {
            // Remove excess dots
            self.dots.removeLast(self.dots.count - count)

            // Check if there is a selected dot. If not, select last element
            if !self.dots.contains(where: \.isSelected) {
                self.select(self.dots[self.dots.endIndex - 1])
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
        let count = count - self.count

        // Create additional dots
        let dots = (0 ..< count).map { _ in Dot(isSelected: false, style: self.style) }

        // Append additional dots
        self.dots.append(contentsOf: dots)
    }
}
