//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SUAppcastItemTests_isCriticalUpdate: SUAppcastItemBaseTests {
    // MARK: isCriticalUpdate() tests
    func test_isCriticalUpdate_nilState_isFalseByDefault() throws {
        let expectedResolvedState: SPUAppcastItemState? = nil
        let dict = self.createBasicAppcastItemDictionary()
        
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualCriticalUpdate = item.isCriticalUpdate
        
        // Assert
        XCTAssertFalse(actualCriticalUpdate)
    }
    
    func test_isCriticalUpdate_stateWithCriticalUpdate_isTrue() throws {
        let expectedResolvedState = SPUAppcastItemState(withMajorUpgrade: false, criticalUpdate: true, informationalUpdate: false, minimumOperatingSystemVersionIsOK: false, maximumOperatingSystemVersionIsOK: false)
        let dict = self.createBasicAppcastItemDictionary()

        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualCriticalUpdate = item.isCriticalUpdate
        
        // Assert
        XCTAssertTrue(actualCriticalUpdate)
    }
}
