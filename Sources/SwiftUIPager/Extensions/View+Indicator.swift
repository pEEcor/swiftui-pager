//
//  View+Indicator.swift
//
//  Copyright © 2023 Paavo Becker.
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
                builder: { AnyView(content($0)) },
                location: location
            )
        )
    }
}
