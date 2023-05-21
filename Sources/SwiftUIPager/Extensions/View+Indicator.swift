//
//  View+Indicator.swift
//  
//
//  Created by Paavo Becker on 21.05.23.
//

import SwiftUI

extension View {
    /// Adds a custom view as a pagers indicator view
    /// - Parameters:
    ///   - location: Optional location where the PageIndicator is placed, defaults to `.bottom`
    ///   - content: A custom Indicator
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
    
    /// Adds an ``IndicatorView`` to a pager in the View hierachy
    /// - Parameters:
    ///   - location: Optional location where the ``IndicatorView`` is placed, defaults to `.bottom`
    ///   - style: Optional style of the ``IndicatorView``, defaults to `nil`
    ///   - content: Optional builder that allows for customization of the ``IndicatorView``
    public func indicator<Content: View>(
        location: IndicatorLocation = .bottom,
        style: IndicatorStyle? = nil,
        @ViewBuilder content: @escaping (IndicatorView) -> Content = { _ in AnyView(EmptyView()) }
    ) -> some View {
        if let style = style {
            return self.environment(
                \.indicator,
                 IndicatorEnvironment(
                    kind: .styled(style, { AnyView(content($0)) }),
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
