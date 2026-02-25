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
    
    @Test func date_parsedFromDateString() throws {
        // Arrange
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)

        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)

        // Act
        let actualAppcastItem = appcast.items.first

        // Assert
        #expect(actualAppcastItem != nil)
        #expect(actualAppcastItem?.dateString == "Sat, 26 Jul 2014 15:20:11 +0000")
        #expect(actualAppcastItem?.date != nil)

        // Verify the date was parsed correctly (in UTC timezone)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: actualAppcastItem!.date!)
        #expect(components.year == 2014)
        #expect(components.month == 7)
        #expect(components.day == 26)
        #expect(components.hour == 15)
        #expect(components.minute == 20)
        #expect(components.second == 11)
    }
    
    @Test func copyByFilteringItems_filterByVersionValue_returnsSingleItem() throws {
        // Arrange
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)

        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)

        // Act - filter to only items with version "2.0"
        let filteredAppcast = appcast.copyByFilteringItems { item in
            item.versionString == "2.0"
        }

        // Assert
        #expect(filteredAppcast.items.count == 1)
        #expect(filteredAppcast.items.first?.versionString == "2.0")
    }
    
    @Test func copyByFilteringItems_filterIsFalsePredicate_returnsNoneItems() throws {
        // Arrange
        let appcastResource = Bundle.module.url(forResource: "appcast_simple", withExtension: "xml")!
        let appcastData = try Data(contentsOf: appcastResource)

        let appcast = try SUAppcast(xmlData: appcastData, relativeTo: nil, stateResolver: nil)

        // Act - filter to empty
        let emptyAppcast = appcast.copyByFilteringItems { _ in false }

        // Assert
        #expect(emptyAppcast.items.count == 0)
    }
}
