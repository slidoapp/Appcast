//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUVersionComparison.h from Sparkle project.
//

import Foundation

/// Provides version comparison facilities for Sparkle.
public protocol SUVersionComparison {
    /// An abstract method to compare two version strings.
    ///
    /// Should return ``ComparisonResult.orderedAscending`` if `versionB > versionA`,
    /// ``ComparisonResult.orderedDescending`` if `versionB < versionA`
    /// and ``ComparisonResult.orderedSame`` if versions are equivalent.
    func compareVersion(_ versionA: String, toVersion versionB: String) -> ComparisonResult
}
