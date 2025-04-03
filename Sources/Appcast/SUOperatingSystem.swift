//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUOperatingSystem.m from Sparkle project.
//

import Foundation

public struct SUOperatingSystem: Sendable {
    public let systemVersionString: String
    
    init() {
        self.init(ProcessInfo.processInfo.operatingSystemVersion)
    }
    
    init(_ version: OperatingSystemVersion) {
        self.systemVersionString = String(format: "%ld.%ld.%ld", version.majorVersion, version.minorVersion, version.patchVersion)
    }
}
