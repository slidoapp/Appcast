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
    
    func test_date_parsedFromDateString() throws {
        // Arrange
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)
        
        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)
        
        // Act
        let actualAppcastItem = appcast.items.first
        
        // Assert
        XCTAssertNotNil(actualAppcastItem)
        XCTAssertEqual(actualAppcastItem?.dateString, "Sat, 26 Jul 2014 15:20:11 +0000")
        XCTAssertNotNil(actualAppcastItem?.date)
        
        // Verify the date was parsed correctly (in UTC timezone)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: actualAppcastItem!.date!)
        XCTAssertEqual(components.year, 2014)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.day, 26)
        XCTAssertEqual(components.hour, 15)
        XCTAssertEqual(components.minute, 20)
        XCTAssertEqual(components.second, 11)
    }
    
    func test_copyByFilteringItems_filterByVersionValue_returnsSingleItem() throws {
        // Arrange
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)
        
        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)
        
        // Act - filter to only items with version "2.0"
        let filteredAppcast = appcast.copyByFilteringItems { item in
            item.versionString == "2.0"
        }
        
        // Assert
        XCTAssertEqual(filteredAppcast.items.count, 1)
        XCTAssertEqual(filteredAppcast.items.first?.versionString, "2.0")
    }
    
    func test_copyByFilteringItems_filterIsFalsePredicate_returnsNoneItems() throws {
        // Arrange
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)
        
        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)
        
        // Act - filter to empty
        let emptyAppcast = appcast.copyByFilteringItems { _ in false }
        
        // Assert
        XCTAssertEqual(emptyAppcast.items.count, 0)
    }
}
