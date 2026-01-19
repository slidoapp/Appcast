//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import Testing
@testable import Appcast

final class SUAppcastItemTests_isMajorUpgrade: SUAppcastItemBaseTests {
    // MARK: isMajorUpgrade() tests
    @Test func isMajorUpgrade_noResolvedState_isFalseByDefault() throws {
        let expectedResolvedState: SPUAppcastItemState? = nil
        let dict = self.createBasicAppcastItemDictionary()
        
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualMajorUpgrade = item.isMajorUpgrade
        
        // Assert
        #expect(!actualMajorUpgrade, "Appcast item must hase isMajorUpgrade set to false")
    }
    
    @Test func isMajorUpgrade_stateWithMajorUpgrade_isTrue() throws {
        let expectedResolvedState = SPUAppcastItemState(withMajorUpgrade: true, criticalUpdate: false, informationalUpdate: false, minimumOperatingSystemVersionIsOK: false, maximumOperatingSystemVersionIsOK: false)
        
        let dict = self.createBasicAppcastItemDictionary()
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualMajorUpgrade = item.isMajorUpgrade
        
        // Assert
        #expect(actualMajorUpgrade, "Appcast item must hase isMajorUpgrade set to true")
    }
}
