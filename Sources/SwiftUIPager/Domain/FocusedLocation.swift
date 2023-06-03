//
//  FocusedLocation.swift
//
//  Copyright © 2023 Paavo Becker.
//

import Foundation

// MARK: - FocusedLocation

/// Location around Indicator that may be focused
enum FocusedLocation {
    /// Location before the the leading edge is focused
    case beforeStart

    /// Location behind the trailing edge is focused
    case behindEnd
}
