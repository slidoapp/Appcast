//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUAppcast.m from Sparkle project.
//

import Foundation

public class SUAppcast {

    public init(xmlData: Data, relativeTo: URL?, stateResolver: SPUAppcastItemStateResolver?) {
        self.items = []
    }

    public let items: [SUAppcastItem]
}
