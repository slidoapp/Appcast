//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import Testing
@testable import Appcast

final class SUAppcastItemTests_isInformationOnlyUpdate: SUAppcastItemBaseTests {
    // MARK: isInformationOnlyUpdate() tests
    @Test func isInformationOnlyUpdate_nilState_isFalseByDefault() throws {
        let expectedResolvedState: SPUAppcastItemState? = nil
        let dict = self.createBasicAppcastItemDictionary()
        
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualInformationOnlyUpdate = item.isInformationOnlyUpdate
        
        // Assert
        #expect(!actualInformationOnlyUpdate)
    }
    
    @Test func isInformationOnlyUpdate_stateWithInformationOnlyUpdate_isTrue() throws {
        let expectedResolvedState = SPUAppcastItemState(withMajorUpgrade: false, criticalUpdate: true, informationalUpdate: true, minimumOperatingSystemVersionIsOK: false, maximumOperatingSystemVersionIsOK: false)
        
        let dict = self.createBasicAppcastItemDictionary()
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualInformationOnlyUpdate = item.isInformationOnlyUpdate
        
        // Assert
        #expect(actualInformationOnlyUpdate)
    }
}
