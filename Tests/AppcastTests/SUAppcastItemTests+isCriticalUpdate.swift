//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SUAppcastItemTests_isCriticalUpdate: SUAppcastItemBaseTests {
    // MARK: isCriticalUpdate() tests
    func test_isCriticalUpdate_nilState_isFalseByDefault() throws {
        // Arrange
        let expectedResolvedState: SPUAppcastItemState? = nil
        let dict = self.createBasicAppcastItemDictionary()
        
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualCriticalUpdate = item.isCriticalUpdate
        
        // Assert
        XCTAssertFalse(actualCriticalUpdate)
    }
    
    func test_isCriticalUpdate_stateWithCriticalUpdate_isTrue() throws {
        // Arrange
        let expectedResolvedState = SPUAppcastItemState(withMajorUpgrade: false, criticalUpdate: true, informationalUpdate: false, minimumOperatingSystemVersionIsOK: false, maximumOperatingSystemVersionIsOK: false)
        let dict = self.createBasicAppcastItemDictionary()

        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: expectedResolvedState)
        
        // Act
        let actualCriticalUpdate = item.isCriticalUpdate
        
        // Assert
        XCTAssertTrue(actualCriticalUpdate)
    }
    
    func test_isCriticalUpdate_dictionaryWithCriticalUpdateInformation_isTrue() throws {
        // Arrange
        let dict = self.createAppcastItemWithCriticalUpdateDictionary()

        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: nil)
        
        // Act
        let actualCriticalUpdate = item.isCriticalUpdate
        
        // Assert
        XCTAssertTrue(actualCriticalUpdate)
    }
    
    func test_isCriticalUpdate_legacyCriticalUpdateInformationInTag_isTrue() throws {
        // Arrange
        let dict = self.createAppcastItemWithLegacyTagWithCriticalUpdateDictionary()

        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: nil)
        
        // Act
        let actualCriticalUpdate = item.isCriticalUpdate
        
        // Assert
        try XCTSkipUnless(actualCriticalUpdate, "Legacy format of critical updates in the <sparkle:tags> element are not supported.")
        XCTAssertTrue(actualCriticalUpdate)
    }
    
    // MARK: - helper functions
    func createAppcastItemWithCriticalUpdateDictionary() -> SUAppcastItemProperties {
        var dict = self.createBasicAppcastItemDictionary()
        
        dict[SUAppcastElement.CriticalUpdate] = SUAppcast.AttributesDictionary()
        
        return dict
    }

    func createAppcastItemWithLegacyTagWithCriticalUpdateDictionary() -> SUAppcastItemProperties {
        var dict = self.createBasicAppcastItemDictionary()
        
        let tags = [SUAppcastElement.CriticalUpdate]
        dict[SUAppcastElement.Tags] = tags
        
        return dict
    }
}
