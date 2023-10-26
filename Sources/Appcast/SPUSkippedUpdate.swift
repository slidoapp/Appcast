//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SPUSkippedUpdate.m from Sparkle project.
//

import Foundation

public struct SPUSkippedUpdate {
    public let minorVersion: String?
    public let majorVersion: String?
    public let majorSubreleaseVersion: String?
    
    init(minorVersion: String?, majorVersion: String?, majorSubreleaseVersion: String?) {
        self.minorVersion = minorVersion
        self.majorVersion = majorVersion
        self.majorSubreleaseVersion = majorSubreleaseVersion
    }
}

