//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SUAppcastItemTests_isInformationOnlyUpdate: XCTestCase {
    // MARK: isInformationOnlyUpdate() tests
    func test_isInformationOnlyUpdate_nilState_isFalseByDefault() throws {
        let expectedResolvedState: SPUAppcastItemState? = nil
        let dict = Dictionary<String, AnyObject>()
        
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualInformationOnlyUpdate = item.isInformationOnlyUpdate()
        
        // Assert
        XCTAssertFalse(actualInformationOnlyUpdate)
    }
    
    func test_isInformationOnlyUpdate_stateWithInformationOnlyUpdate_isTrue() throws {
        let expectedResolvedState = SPUAppcastItemState(withMajorUpgrade: false, criticalUpdate: true, informationalUpdate: true, minimumOperatingSystemVersionIsOK: false, maximumOperatingSystemVersionIsOK: false)
        
        let dict = Dictionary<String, AnyObject>()
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualInformationOnlyUpdate = item.isInformationOnlyUpdate()
        
        // Assert
        XCTAssertTrue(actualInformationOnlyUpdate)
    }
}
