//
//  File.swift
//  
//
//  Created by Paavo Becker on 25.07.24.
//

import Foundation

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

public enum Axis {
    case horizontal
    case vertical
}
