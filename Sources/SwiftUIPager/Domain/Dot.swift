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
    private(set) var width: CGFloat
    
    /// State of the dot
    private(set) var isSelected: Bool
    
    private let style: PageIndicatorStyle
    
    init(
        isSelected: Bool,
        style: PageIndicatorStyle
    ) {
        self.isSelected = isSelected
        self.style = style
        
        if isSelected {
            self.width = style.focused.shape.width
        } else {
            self.width = style.plain.shape.width
        }
    }
    
    mutating func select() {
        self.isSelected = true
        self.width = style.focused.shape.width
    }
    
    mutating func deselect() {
        self.isSelected = false
        self.width = style.plain.shape.width
    }
}
