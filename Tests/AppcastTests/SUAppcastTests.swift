//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastTests: XCTestCase {
    func test_init_simpleAppcastFile() throws {
        // Arrange
        let expectedItemsCount = 1
        
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)
        
        // Act
        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)
        
        let actualItemsCount = appcast.items.count
        
        // Assert
        XCTAssertEqual(actualItemsCount, expectedItemsCount)
    }
    
    func test_items_simpleAppcast_createsAppcastItem() throws {
        // Arrange
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)
        
        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)
        
        // Act
        let actualAppcastItem = appcast.items.first
        
        // Assert
        XCTAssertNotNil(actualAppcastItem)
        XCTAssertEqual(actualAppcastItem?.title, "Version 2.0")
        XCTAssertEqual(actualAppcastItem?.versionString, "2.0")
    }
}
