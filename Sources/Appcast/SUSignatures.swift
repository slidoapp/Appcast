//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUSignatures.m from Sparkle project.
//

public struct SUSignatures: Sendable {
    public let ed25519: String

    public init(ed ed25519: String) {
        self.ed25519 = ed25519
    }
}
