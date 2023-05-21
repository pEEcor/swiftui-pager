//
//  Dot.swift
//  
//
//  Created by Paavo Becker on 31.03.23.
//

import Foundation

/// Indicator Model
struct Dot {
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
