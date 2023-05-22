//
//  IndicatorEnvironment.swift
//
//  Copyright © 2023 Paavo Becker.
//

import SwiftUI

typealias PageIndicatorBuilder = (Binding<Int>) -> AnyView
typealias BackgroundBuilder = (IndicatorView) -> AnyView

// MARK: - IndicatorEnvironment

struct IndicatorEnvironment {
    let kind: IndicatorKind?
    let location: IndicatorLocation

    static var `default`: Self {
        IndicatorEnvironment(
            kind: .styled(.default) { _ in AnyView(EmptyView()) },
            location: .bottom
        )
    }
}

// MARK: - IndicatorKind

enum IndicatorKind {
    case styled(IndicatorStyle, BackgroundBuilder)
    case custom(PageIndicatorBuilder)
}

// MARK: - IndicatorLocation

public enum IndicatorLocation {
    case top
    case bottom
}

// MARK: - IndicatorKey

struct IndicatorKey: EnvironmentKey {
    typealias Value = IndicatorEnvironment

    static var defaultValue: Value = .default
}

extension EnvironmentValues {
    var indicator: IndicatorKey.Value {
        get { self[IndicatorKey.self] }
        set { self[IndicatorKey.self] = newValue }
    }
}
