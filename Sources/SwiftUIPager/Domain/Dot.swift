//
//  Dot.swift
//
//  Copyright © 2023 Paavo Becker.
//

import Foundation

/// Indicator Model
struct Dot: Sendable {
    /// Width of the dot
    var width: Double {
        return self.isSelected ? self.style.focused.shape.width : self.style.plain.shape.width
    }

    /// Height of the dot
    var height: Double {
        return self.isSelected ? self.style.focused.shape.height : self.style.plain.shape.height
    }

    /// State of the dot
    private(set) var isSelected: Bool

    private let style: IndicatorStyle

    init(
        isSelected: Bool,
        style: IndicatorStyle
    ) {
        self.isSelected = isSelected
        self.style = style
    }

    mutating func select() {
        self.isSelected = true
    }

    mutating func deselect() {
        self.isSelected = false
    }
}
