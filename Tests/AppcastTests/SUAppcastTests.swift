//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import Foundation
import Testing
@testable import Appcast

struct SUAppcastTests {
    @Test func init_simpleAppcastFile() throws {
        // Arrange
        let expectedItemsCount = 1
        
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)
        
        // Act
        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)
        
        let actualItemsCount = appcast.items.count
        
        // Assert
        #expect(actualItemsCount == expectedItemsCount)
    }
    
    @Test func items_simpleAppcast_createsAppcastItem() throws {
        // Arrange
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)
        
        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)
        
        // Act
        let actualAppcastItem = appcast.items.first
        
        // Assert
        #expect(actualAppcastItem != nil)
        #expect(actualAppcastItem?.title == "Version 2.0")
        #expect(actualAppcastItem?.versionString == "2.0")
    }
}
