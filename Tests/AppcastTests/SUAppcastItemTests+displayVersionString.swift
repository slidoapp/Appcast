//
// Copyright 2024 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SUAppcastItemTests_displayVersionString: SUAppcastItemBaseTests {
    // MARK: displayVersionString() tests
    /// When update has only the `<sparkle:version>` element the ``SUAppcastItem.displayVersionString`` value is equal to the ``SUAppcastItem.versionString`` value.
    func test_displayVersionString_appcastWithoutSparkleShortVersionStringValue() throws {
        // Arrange
        let item = try self.createAppcastItemWithShortVersionString(sparkleVersion: "1.4.8", sparkleShortVersion: nil)
        
        // Act
        let version = item.versionString
        let displayVersion = item.displayVersionString
        
        // Assert
        XCTAssertEqual("1.4.8", version)
        XCTAssertEqual(version, displayVersion)
    }
    
    /// When update has the `<sparkle:sparkleShortVersion>` element, use it for the ``SUAppcastItem.displayVersionString`` value.
    func test_displayVersionString_appcastWithSparkleShortVersionStringElement() throws {
        // Arrange
        let item = try self.createAppcastItemWithShortVersionString(sparkleVersion: "1799", sparkleShortVersion: "2.3.0")
        
        // Act
        let version = item.versionString
        let displayVersion = item.displayVersionString
        
        // Assert
        XCTAssertEqual("1799", version)
        XCTAssertEqual("2.3.0", displayVersion)
    }
    
    /// Sparkle 1.0 supports the `<enclosure sparkle:shortVersionString="1.0.2">` attribute.
    /// This value is prefered over the `<sparkle:sparkleShortVersion>` element based on the original implementation.
    func test_displayVersionString_enclosureElementWithShortVersionStringAttribute() throws {
        // Arrange
        let item = try self.createLegacyAppcastItemWithEnclosureShortVersionString(sparkleVersion: "1430", sparkleShortVersion: "1.0.2")
        
        // Act
        let version = item.versionString
        let displayVersion = item.displayVersionString
        
        // Assert
        XCTAssertEqual("1430", version)
        XCTAssertEqual("1.0.2", displayVersion)
    }

    // MARK: helper methods for creating test data
    func createAppcastItemWithShortVersionString(sparkleVersion: String, sparkleShortVersion: String?) throws -> SUAppcastItem {
        var dict = self.createBasicAppcastItemDictionary()
        
        dict[SUAppcastElement.Version] = sparkleVersion
        if let sparkleShortVersion {
            dict[SUAppcastElement.ShortVersionString] = sparkleShortVersion
        }
        
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: nil)
        return item
    }
    
    func createLegacyAppcastItemWithEnclosureShortVersionString(sparkleVersion: String, sparkleShortVersion: String) throws -> SUAppcastItem {
        var enclosure = SUAppcastItemProperties()
        enclosure[SUAppcastAttribute.ShortVersionString] = sparkleShortVersion
        
        var dict = self.createBasicAppcastItemDictionary()
        
        dict[SUAppcastElement.Version] = sparkleVersion
        dict[SURSSElement.Enclosure] = enclosure
        
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: nil)
        return item
    }
}
