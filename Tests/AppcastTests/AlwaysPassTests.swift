//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import Testing
@testable import Appcast

/// Ensures at least one unit test will pass.
struct AlwaysPassTests {
    @Test func alwaysPass() {
        #expect(Bool(true), "This test will always pass.")
    }
}
