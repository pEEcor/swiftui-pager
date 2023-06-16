//
//  IndicatorEnvironment.swift
//
//  Copyright © 2023 Paavo Becker.
//

import SwiftUI

typealias PageIndicatorBuilder = (Binding<Int>) -> AnyView

// MARK: - IndicatorEnvironment

struct IndicatorEnvironment {
    let builder: PageIndicatorBuilder
    let location: IndicatorLocation
}

// MARK: - IndicatorLocation

public enum IndicatorLocation {
    case top
    case bottom
}

// MARK: - IndicatorKey

struct IndicatorKey: EnvironmentKey {
    static var defaultValue: IndicatorEnvironment? = nil
}

extension EnvironmentValues {
    var indicator: IndicatorKey.Value {
        get { self[IndicatorKey.self] }
        set { self[IndicatorKey.self] = newValue }
    }
}
