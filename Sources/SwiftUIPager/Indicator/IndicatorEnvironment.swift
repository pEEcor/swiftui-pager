//
//  PageIndicatorEnvironment.swift
//  
//
//  Created by Paavo Becker on 09.03.23.
//

import SwiftUI

typealias PageIndicatorBuilder = (Binding<Int>) -> AnyView
typealias BackgroundBuilder = (IndicatorView) -> AnyView

struct IndicatorEnvironment {
    let kind: IndicatorKind?
    let location: IndicatorLocation
    
    static var `default`: Self {
        IndicatorEnvironment(
            kind: .styled(.default, { _ in AnyView(EmptyView()) }),
            location: .bottom
        )
    }
}

enum IndicatorKind {
    case styled(IndicatorStyle, BackgroundBuilder)
    case custom(PageIndicatorBuilder)
}

public enum IndicatorLocation {
    case top
    case bottom
}

struct PageIndicatorKey: EnvironmentKey {
    typealias Value = IndicatorEnvironment
    
    static var defaultValue: Value = .default
}

extension EnvironmentValues {
    var indicator: PageIndicatorKey.Value {
        get { self[PageIndicatorKey.self] }
        set { self[PageIndicatorKey.self] = newValue }
    }
}

extension View {
    /// Controls the appearance of the PageIndicator of a PagerView
    /// - Parameters:
    ///   - location: The location where the PageIndicator is placed
    ///   - content: A custom PageIndicator
    public func indicator<Content: View>(
        location: IndicatorLocation = .bottom,
        @ViewBuilder content: @escaping (Binding<Int>) -> Content
    ) -> some View {
        self.environment(
            \.indicator,
             IndicatorEnvironment(
                kind: .custom({ AnyView(content($0)) }),
                location: location
             )
        )
    }
    
    /// Controls the appearance of the PageIndicator of a PagerView
    /// - Parameters:
    ///   - location: The location where the PageIndicator is placed
    ///   - style: The style of the default PageIndicator
    public func indicator<Background: View>(
        location: IndicatorLocation = .bottom,
        style: IndicatorStyle? = nil,
        @ViewBuilder background: @escaping (IndicatorView) -> Background = { _ in AnyView(EmptyView()) }
    ) -> some View {
        if let style = style {
            return self.environment(
                \.indicator,
                 IndicatorEnvironment(
                    kind: .styled(style, { AnyView(background($0)) }),
                    location: location
                 )
            )
        } else {
            return self.environment(
                \.indicator,
                 IndicatorEnvironment(
                    kind: nil,
                    location: location
                 )
            )
        }
    }
}
