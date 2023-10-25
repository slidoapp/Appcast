//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

/// Ensures at least one unit test will pass.
final class AlwaysPassTests: XCTestCase {
    func test_alwaysPass() throws {
        XCTAssertTrue(true, "This test will always pass.")
    }
}
