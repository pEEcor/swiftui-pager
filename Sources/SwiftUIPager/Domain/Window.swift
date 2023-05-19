//
//  Window.swift
//  
//
//  Created by Paavo Becker on 29.04.23.
//

struct Window {
    /// The offset that is applied to the window
    private(set) var offset: Double
    
    /// The width of the window
    private(set) var width: Double
    
    /// The leading edge of the window
    var min: Double {
        self.offset
    }
    
    /// the trailing edge of the window
    var max: Double {
        self.offset + self.width
    }
    
    /// Creates a window
    ///
    /// - Parameters:
    ///   - offset: The initial offset of the window
    ///   - width: The initial width of the window
    init(
        offset: Double,
        width: Double
    ) {
        self.offset = offset
        self.width = width
    }
    
    /// For a given offset this method returns the location that is targeted around the window.
    ///
    /// If an area inside the window is focused, `nil` is retured.
    /// - Parameter offset: The offset to get location for
    /// - Returns: Location that is targeted by offset
    func focusedArea(for offset: Double) -> FocusedArea? {
        if self.offset - offset < 0 {
            return .beforeStart
        } else if self.offset - offset > 0 {
            return .behindEnd
        } else {
            return nil
        }
    }
    
    /// Resizes the Window to the given width
    ///
    /// - Parameter width: The new width of the window
    mutating func setWidth(to width: Double) {
        self.width = width
    }
    
    /// Sets the window's offset to the given offset
    ///
    /// - Parameter offset: The new offset of the window
    mutating func setOffset(to offset: Double) {
        self.offset = offset
    }
}
