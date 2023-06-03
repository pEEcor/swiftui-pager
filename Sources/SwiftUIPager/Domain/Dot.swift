//
//  Dot.swift
//
//  Copyright © 2023 Paavo Becker.
//

import Foundation

/// Indicator Model
struct Dot: Sendable, Identifiable {
    /// Unique id of the dot
    let id: UUID

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
        style: IndicatorStyle,
        id: UUID = UUID()
    ) {
        self.isSelected = isSelected
        self.style = style
        self.id = id
    }

    mutating func select() {
        self.isSelected = true
    }

    mutating func deselect() {
        self.isSelected = false
    }
}
