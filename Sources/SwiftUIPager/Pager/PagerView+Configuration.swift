//
//  PagerView+Configuration.swift
//
//  Copyright © 2024 Paavo Becker.
//

import Foundation

// MARK: - PagerView.Configuration

extension PagerView {
    /// Configuration options for a ``PagerView``.
    public struct Configuration {
        /// The scroll direction happens along this axis.
        let axis: Axis

        public init(axis: Axis) {
            self.axis = axis
        }
    }
}

extension PagerView.Configuration {
    public static var `default`: Self {
        PagerView.Configuration(axis: .horizontal)
    }
}

// MARK: - Axis

public enum Axis {
    case horizontal
    case vertical
}
