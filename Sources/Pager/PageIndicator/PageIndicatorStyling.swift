import Foundation
import SwiftUI

/// Styling Options for the entire PageIndicator
public struct PageIndicatorSytling {
    let plain: PageIndicatorDotStyle
    let focused: PageIndicatorDotStyle
    let spacing: CGFloat
    
    /// Creates a styling definition for an entire PageIndicator
    /// - Parameters:
    ///   - plainStyle: Style of a single PageIndicator dot
    ///   - focusedStyle: Style of the PageIndicator dot that represents the currently active page
    ///   - spacing: Spacing between the individual PageIndicator dots
    public init(
        plainStyle: PageIndicatorDotStyle = .default,
        focusedStyle: PageIndicatorDotStyle = .default,
        spacing: CGFloat = 10
    ) {
        self.plain = plainStyle
        self.focused = focusedStyle
        self.spacing = spacing
    }
    
    public static var `default`: Self {
        PageIndicatorSytling()
    }
}

public struct PageIndicatorDotStyle {
    public var shape: Shape
    public var color: Color
    
    public init(
        shape: Shape = .circle(radius: 10),
        color: Color = .accentColor
    ) {
        self.shape = shape
        self.color = color
    }
    
    public static func circle(
        radius: CGFloat,
        color: Color = .accentColor
    ) -> Self {
        PageIndicatorDotStyle(shape: .circle(radius: radius), color: color)
    }
    
    public static func rect(
        size: CGSize,
        color: Color = .accentColor
    ) -> Self {
        PageIndicatorDotStyle(shape: .rect(size: size), color: color)
    }
    
    public static var `default`: Self {
        PageIndicatorDotStyle()
    }
    
    public enum Shape {
        case circle(radius: CGFloat)
        case rect(size: CGSize)
        
        var width: CGFloat {
            switch self {
            case .circle(radius: let radius):
                return radius
            case .rect(size: let size):
                return size.width
            }
        }
        
        var height: CGFloat {
            switch self {
            case .circle(radius: let radius):
                return radius
            case .rect(size: let size):
                return size.height
            }
        }
    }
}

