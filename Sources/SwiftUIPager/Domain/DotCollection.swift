//
//  DotCollection.swift
//  
//
//  Created by Paavo Becker on 31.03.23.
//

import Foundation

enum Edge {
    case leading
    case trailing
}

/// A Collection that holds a dot model for each dot in the page indicator
struct DotCollection {
    /// The amount of dots in the collection
    var count: Int {
        self.dots.count
    }
    
    /// The index of the selected dot
    var selectedIndex: Int? {
        self.dots.firstIndex(where: { $0.isSelected })
    }
    
    /// The width of the dot collection
    var width: Double {
        // Calculate width of all dots
        let dotsWidth = dots.reduce(0) { partialResult, dot in
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
    
    private var dots: [Dot]
    private let style: PageIndicatorStyle
    
    init(
        count: Int,
        style: PageIndicatorStyle
    ) {
        self.style = style
        self.dots = Array(
            repeating: Dot(
                isSelected: false,
                style: style
            ),
            count: count
        )
        
        if !self.dots.isEmpty {
            self.dots[0].select()
        }
    }
    
    subscript(index: Int) -> Dot? {
        guard index >= 0 && index < self.dots.count else {
            return nil
        }
        
        return self.dots[index]
    }
    
    func filter(_ isIncluded: (Dot) throws -> Bool) rethrows -> [Dot] {
        try self.dots.filter(isIncluded)
    }
    
    /// Calculates the offset to the selected respecting the styling of all preceding dots
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
    
    func calcOffsetOfSelectedDot(
        at edge: Edge,
        in window: Window
    ) -> Double? {
        // Make sure a dot is selected
        guard let _ = self.selectedIndex else {
            return nil
        }
        
        let includeDotWidth = {
            switch edge {
            case .leading:
                return false
            case .trailing:
                return true
            }
        }()
        
        guard let offset = self.getOffsetToSelectedDot(includeWidth: includeDotWidth) else {
            return nil
        }
        
        switch edge {
        case .leading where offset + window.width > self.width:
            return self.width - window.width
        case .trailing where offset < window.width:
            return 0
        case .leading:
            return offset
        case .trailing:
            return self.width - window.width
        }
    }
    
    /// Returns true if selected dot is fully visibile inside the given window
    /// - Parameter window: The window that describes the visible section of the page indicator dot collection
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
    /// If the given index is part of the collection of dots, then the dot with the given index gets selected and the current selection gets
    /// canceled. The selections stays unchanged if the index is not part of the collection.
    /// - Parameter index: Index of the dot that should be selected
    mutating func select(index: Int) {
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
    }
    
    mutating func change(count: Int) {
        if count < self.dots.count {
            // Remove excess dots
            self.dots.removeLast(dots.count - count)
            
            // Check if there is a selected dot. If not, select last element
            if !dots.contains(where: { $0.isSelected }) {
                self.select(index: self.dots.endIndex - 1)
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
