//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SPUAppcastItemStateTests: XCTestCase {

    func test_init() throws {
        // Arrange
        // Act
        let itemState = SPUAppcastItemState(withMajorUpgrade: true, criticalUpdate: true, informationalUpdate: true, minimumOperatingSystemVersionIsOK: true, maximumOperatingSystemVersionIsOK: true)

        // Assert
        XCTAssertTrue(itemState.majorUpgrade)
        XCTAssertTrue(itemState.criticalUpdate)
        XCTAssertTrue(itemState.informationalUpdate)
        XCTAssertTrue(itemState.minimumOperatingSystemVersionIsOK)
        XCTAssertTrue(itemState.maximumOperatingSystemVersionIsOK)
    }
}
