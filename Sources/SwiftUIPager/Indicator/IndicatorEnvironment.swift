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
