import Foundation
import SwiftUI

/// Style Options for the entire PageIndicator
public struct PageIndicatorStyle: Equatable {
    let plain: PageIndicatorDotStyle
    let focused: PageIndicatorDotStyle
    let spacing: CGFloat
    let width: PageIndicatorWidth
    
    /// Creates a style definition for an entire PageIndicator
    /// - Parameters:
    ///   - plainStyle: Style of a single PageIndicator dot
    ///   - focusedStyle: Style of the PageIndicator dot that represents the currently active page
    ///   - spacing: Spacing between the individual PageIndicator dots
    public init(
        plainStyle: PageIndicatorDotStyle = .default,
        focusedStyle: PageIndicatorDotStyle = .default,
        spacing: CGFloat = 10,
        width: PageIndicatorWidth = .infinite
    ) {
        self.plain = plainStyle
        self.focused = focusedStyle
        self.spacing = spacing
        self.width = width
    }
    
    public static var `default`: Self {
        PageIndicatorStyle(
            plainStyle: .circle(radius: 8, color: .gray.opacity(0.7)),
            focusedStyle: .circle(radius: 10, color: .white),
            spacing: 8,
            width: .infinite
        )
    }
}

public enum PageIndicatorWidth: Equatable {
    case infinite
    case constant(CGFloat)
}

public struct PageIndicatorDotStyle: Equatable {
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
    
    public enum Shape: Equatable {
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

