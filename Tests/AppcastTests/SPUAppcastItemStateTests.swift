//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import Testing
@testable import Appcast

struct SPUAppcastItemStateTests {

    @Test func init_SPUAppcastItemState() throws {
        // Arrange
        // Act
        let itemState = SPUAppcastItemState(withMajorUpgrade: true, criticalUpdate: true, informationalUpdate: true, minimumOperatingSystemVersionIsOK: true, maximumOperatingSystemVersionIsOK: true)

        // Assert
        #expect(itemState.majorUpgrade)
        #expect(itemState.criticalUpdate)
        #expect(itemState.informationalUpdate)
        #expect(itemState.minimumOperatingSystemVersionIsOK)
        #expect(itemState.maximumOperatingSystemVersionIsOK)
    }
}
