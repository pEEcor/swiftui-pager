import Foundation
import SwiftUI

/// Style Options for the entire PageIndicator
public struct IndicatorStyle: Equatable {
    /// The style of a normal dot
    let plain: DotStyle
    
    /// The style of a dot represinting the active page
    let focused: DotStyle
    
    /// The spacing between dots
    let spacing: CGFloat
    
    /// Creates a style definition for a page indicator
    /// - Parameters:
    ///   - plainStyle: Style of a single page indicator dot
    ///   - focusedStyle: Style of the page indicator dot that represents the currently active page
    ///   - spacing: Spacing between the individual page indicator dots
    public init(
        plainStyle: DotStyle = .default,
        focusedStyle: DotStyle = .default,
        spacing: CGFloat = 10
    ) {
        self.plain = plainStyle
        self.focused = focusedStyle
        self.spacing = spacing
    }
    
    /// The default style using sensible default values
    public static var `default`: Self {
        IndicatorStyle(
            plainStyle: .circle(radius: 8, color: .gray.opacity(0.7)),
            focusedStyle: .circle(radius: 10, color: .white),
            spacing: 8
        )
    }
}

/// Style definition for a single page indicator dot
public struct DotStyle: Equatable {
    /// The shape of the dot
    public let shape: Shape
    
    /// The color of the dot
    public let color: Color
    
    /// Creates a style definition for a page indicator dot
    /// - Parameters:
    ///   - shape: The shape of the dot
    ///   - color: The color of the dot
    public init(
        shape: Shape = .circle(radius: 10),
        color: Color = .accentColor
    ) {
        self.shape = shape
        self.color = color
    }
    
    /// Creates a style definition for a cirle shaped page indicator dot
    /// - Parameters:
    ///   - radius: The radius of the dot
    ///   - color: The color of the dot, defaults to accent color
    /// - Returns: A page indicator dot style
    public static func circle(
        radius: CGFloat,
        color: Color = .accentColor
    ) -> Self {
        DotStyle(shape: .circle(radius: radius), color: color)
    }
    
    /// Creates a style definition for a rectangular shaped page indicator dot
    /// - Parameters:
    ///   - size: The size of the dot
    ///   - color: The color of the dot, defaults to accent color
    /// - Returns: A page indicator dot style
    public static func rect(
        size: CGSize,
        color: Color = .accentColor
    ) -> Self {
        DotStyle(shape: .rect(size: size), color: color)
    }
    
    /// The default style using sensible default values
    public static var `default`: Self {
        DotStyle()
    }
    
    /// Shape Definition of a page indicator dot
    public enum Shape: Equatable {
        /// Circle shape
        case circle(radius: CGFloat)
        
        /// Rectangle shape
        case rect(size: CGSize)
        
        /// The width of the shape
        var width: CGFloat {
            switch self {
            case .circle(radius: let radius):
                return radius
            case .rect(size: let size):
                return size.width
            }
        }
        
        /// The height of the shape
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

