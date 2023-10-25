//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUOperatingSystem.m from Sparkle project.
//

import Foundation

public class SUOperatingSystem {
    public static var systemVersionString: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return String(format: "%ld.%ld.%ld", version.majorVersion, version.minorVersion, version.patchVersion)
    }
}
