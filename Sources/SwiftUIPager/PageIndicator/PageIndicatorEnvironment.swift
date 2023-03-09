//
//  PageIndicatorEnvironment.swift
//  
//
//  Created by Paavo Becker on 09.03.23.
//

import SwiftUI

typealias PageIndicatorBuilder = (Binding<Int>) -> AnyView

struct PageIndicatorEnvironment {
    
    let kind: PageIndicatorKind
    let location: PageIndicatorLocation
    
    static var `default`: Self {
        PageIndicatorEnvironment(
            kind: .default(.default),
            location: .bottom
        )
    }
}

enum PageIndicatorKind {
    case `default`(PageIndicatorStyle)
    case custom(PageIndicatorBuilder)
}

public enum PageIndicatorLocation {
    case top
    case bottom
}

struct PageIndicatorKey: EnvironmentKey {
    typealias Value = PageIndicatorEnvironment
    
    static var defaultValue: Value = .default
}

extension EnvironmentValues {
    var pageIndicator: PageIndicatorKey.Value {
        get { self[PageIndicatorKey.self] }
        set { self[PageIndicatorKey.self] = newValue }
    }
}

extension View {
    /// Controls the appearance of the PageIndicator of a PagerView
    /// - Parameters:
    ///   - location: The location where the PageIndicator is placed
    ///   - content: A custom PageIndicator
    public func pageIndicator<Content: View>(
        location: PageIndicatorLocation = .bottom,
        @ViewBuilder content: @escaping (Binding<Int>) -> Content
    ) -> some View {
        self.environment(
            \.pageIndicator,
             PageIndicatorEnvironment(
                kind: .custom({ AnyView(content($0)) }),
                location: location
             )
        )
    }
    
    /// Controls the appearance of the PageIndicator of a PagerView
    /// - Parameters:
    ///   - location: The location where the PageIndicator is placed
    ///   - style: The style of the default PageIndicator
    public func pageIndicator(
        location: PageIndicatorLocation = .bottom,
        style: PageIndicatorStyle = .default
    ) -> some View {
        self.environment(
            \.pageIndicator,
             PageIndicatorEnvironment(
                kind: .default(style),
                location: location
             )
        )
    }
}
