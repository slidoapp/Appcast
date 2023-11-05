//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastChannelTests: XCTestCase {
    var appcast = SUAppcast.empty
    
    override func setUpWithError() throws {
        guard let testURL = Bundle.module.url(forResource: "testappcast_channels", withExtension: "xml") else {
            fatalError("Resource file is not bundled in integration test.")
        }
        
        let testData = try Data(contentsOf: testURL)
        
        let versionComparator = SUStandardVersionComparator.default
        let hostVersion = "1.0"
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
        
        self.appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
    }
    
    func test_items_count() {
        // Arrange
        let actualCount = self.appcast.items.count
        
        // Assert
        XCTAssertEqual(6, actualCount)
    }
    
    func test_filterAppcast_noChannels() {
        // Arrange
        let expectedChannels = [String]()

        // Act
        let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: expectedChannels)
        
        // Assert
        XCTAssertEqual(2, filteredAppcast.items.count)
        XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
        XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
    }
    
    
    func test_filterAppcast_singleBetaChannel() {
        // Arrange
        let expectedChannels = ["beta"]

        // Act
        let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: expectedChannels)
        
        // Assert
        XCTAssertEqual(3, filteredAppcast.items.count)
        XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
        XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
        XCTAssertEqual("4.0", filteredAppcast.items[2].versionString)
    }

    func test_filterAppcast_singleNightlyChannel() {
        // Arrange
        let expectedChannels = ["nightly"]

        // Act
        let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: expectedChannels)
        
        // Assert
        XCTAssertEqual(3, filteredAppcast.items.count)
        XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
        XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
        XCTAssertEqual("5.0", filteredAppcast.items[2].versionString)
    }
    
    func test_filterAppcast_singleNonExistingChannel() {
        // Arrange
        let expectedChannels = ["madeup"]

        // Act
        let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: expectedChannels)
        
        // Assert
        XCTAssertEqual(2, filteredAppcast.items.count)
        XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
        XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
    }
    
    func test_filterAppcast_multipleChannels() {
        // Arrange
        let expectedChannels = ["beta", "nightly"]

        // Act
        let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: expectedChannels)
        
        // Assert
        XCTAssertEqual(4, filteredAppcast.items.count)
        XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
        XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
        XCTAssertEqual("4.0", filteredAppcast.items[2].versionString)
        XCTAssertEqual("5.0", filteredAppcast.items[3].versionString)
    }
}
