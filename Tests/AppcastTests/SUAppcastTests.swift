//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastTests: XCTestCase {
    func testExample() throws {
        // Arrange
        let expectedItemsCount = 1
        
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)
        
        // Act
        let appcast = SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)
        
        let actualItemsCount = appcast.items.count
        
        // Assert
        XCTAssertEqual(actualItemsCount, expectedItemsCount)
    }
}
