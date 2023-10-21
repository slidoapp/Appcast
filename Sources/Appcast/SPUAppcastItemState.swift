//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SPUAppcastItemState.m from Sparkle project.
//

import Foundation

public struct SPUAppcastItemState {
    public let majorUpgrade: Bool
    public let criticalUpdate: Bool
    public let informationalUpdate: Bool
    public let minimumOperatingSystemVersionIsOK: Bool
    public let maximumOperatingSystemVersionIsOK: Bool

    public init(withMajorUpgrade majorUpgrade: Bool, criticalUpdate: Bool, informationalUpdate: Bool, minimumOperatingSystemVersionIsOK: Bool, maximumOperatingSystemVersionIsOK: Bool) {
        self.majorUpgrade = majorUpgrade
        self.criticalUpdate = criticalUpdate
        self.informationalUpdate = informationalUpdate
        self.minimumOperatingSystemVersionIsOK = minimumOperatingSystemVersionIsOK
        self.maximumOperatingSystemVersionIsOK = maximumOperatingSystemVersionIsOK
    }
}
