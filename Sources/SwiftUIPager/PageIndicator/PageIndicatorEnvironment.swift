//
//  PageIndicatorEnvironment.swift
//  
//
//  Created by Paavo Becker on 09.03.23.
//

import SwiftUI

typealias PageIndicatorBuilder = (Binding<Int>) -> AnyView
typealias BackgroundBuilder = (PageIndicatorView) -> AnyView

struct PageIndicatorEnvironment {
    let kind: PageIndicatorKind?
    let location: PageIndicatorLocation
    
    static var `default`: Self {
        PageIndicatorEnvironment(
            kind: .styled(.default, { _ in AnyView(EmptyView()) }),
            location: .bottom
        )
    }
}

enum PageIndicatorKind {
    case styled(PageIndicatorStyle, BackgroundBuilder)
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
    public func pageIndicator<Background: View>(
        location: PageIndicatorLocation = .bottom,
        style: PageIndicatorStyle? = nil,
        @ViewBuilder background: @escaping (PageIndicatorView) -> Background = { _ in AnyView(EmptyView()) }
    ) -> some View {
        if let style = style {
            return self.environment(
                \.pageIndicator,
                 PageIndicatorEnvironment(
                    kind: .styled(style, { AnyView(background($0)) }),
                    location: location
                 )
            )
        } else {
            return self.environment(
                \.pageIndicator,
                 PageIndicatorEnvironment(
                    kind: nil,
                    location: location
                 )
            )
        }
    }
}
