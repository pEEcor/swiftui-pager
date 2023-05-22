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
        if self.isSelected {
            return self.style.focused.shape.width
        } else {
            return self.style.plain.shape.width
        }
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
