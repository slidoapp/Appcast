//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SPUAppcastItemState.m from Sparkle project.
//

import Foundation

public struct SPUAppcastItemState: Sendable, Equatable {
    public let majorUpgrade: Bool
    public let criticalUpdate: Bool
    public let informationalUpdate: Bool
    public let minimumUpdateVersionIsOK: Bool
    public let minimumOperatingSystemVersionIsOK: Bool
    public let maximumOperatingSystemVersionIsOK: Bool
    public let arm64HardwareRequirementIsOK: Bool

    public init(
        withMajorUpgrade majorUpgrade: Bool,
        criticalUpdate: Bool,
        informationalUpdate: Bool,
        minimumUpdateVersionIsOK: Bool = true,
        minimumOperatingSystemVersionIsOK: Bool,
        maximumOperatingSystemVersionIsOK: Bool,
        arm64HardwareRequirementIsOK: Bool = true
    ) {
        self.majorUpgrade = majorUpgrade
        self.criticalUpdate = criticalUpdate
        self.informationalUpdate = informationalUpdate
        self.minimumUpdateVersionIsOK = minimumUpdateVersionIsOK
        self.minimumOperatingSystemVersionIsOK = minimumOperatingSystemVersionIsOK
        self.maximumOperatingSystemVersionIsOK = maximumOperatingSystemVersionIsOK
        self.arm64HardwareRequirementIsOK = arm64HardwareRequirementIsOK
    }
}
