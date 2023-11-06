//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastParserTest: XCTestCase {
    var appcast = SUAppcast.empty
    
    override func setUpWithError() throws {
        guard let testURL = Bundle.module.url(forResource: "testappcast", withExtension: "xml") else {
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
        XCTAssertEqual(4, actualCount)
    }
    
    /// Test scenario: First release.
    func test_items_item0() {
        // Arrange
        let actualItem = self.appcast.items[0]
        
        // Assert
        XCTAssertEqual("Version 2.0", actualItem.title)
        XCTAssertEqual("desc", actualItem.itemDescription)
        XCTAssertEqual("plain-text", actualItem.itemDescriptionFormat)
        XCTAssertEqual("Sat, 26 Jul 2014 15:20:11 +0000", actualItem.dateString)
        XCTAssertTrue(actualItem.isCriticalUpdate)
        XCTAssertEqual(actualItem.versionString, "2.0")
    }
    
    /// Test scenario: This is the best release matching our system version.
    func test_items_item1_bestReleaseMatchingSystemVersion() {
        // Arrange
        let actualItem = self.appcast.items[1]
        
        // Assert
        XCTAssertEqual("Version 3.0", actualItem.title)
        XCTAssertEqual("desc3", actualItem.itemDescription)
        XCTAssertEqual("html", actualItem.itemDescriptionFormat)
        XCTAssertNil(actualItem.dateString)
        // TODO: legacy critical update information inside <sparkle:tags> element is not implemented yet
        XCTAssertTrue(actualItem.isCriticalUpdate)
        XCTAssertEqual(actualItem.phasedRolloutInterval, 86400)
        XCTAssertEqual(actualItem.versionString, "3.0")
    }
    
    /// Test scenario: A release testing `minimumSystemVersion`.
    func test_items_item2() {
        // Arrange
        let actualItem = self.appcast.items[2]
        
        // Assert
        XCTAssertEqual("Version 4.0", actualItem.title)
        XCTAssertNil(actualItem.itemDescription)
        XCTAssertEqual("Sat, 26 Jul 2014 15:20:13 +0000", actualItem.dateString)
        XCTAssertFalse(actualItem.isCriticalUpdate)
    }
    
    /// Test scenario: A joke release testing `maximumSystemVersion`.
    func test_items_item3() {
        // Arrange
        let actualItem = self.appcast.items[3]
        
        // Assert
        XCTAssertEqual("Version 5.0", actualItem.title)
        XCTAssertNil(actualItem.itemDescription)
        XCTAssertNil(actualItem.dateString)
        XCTAssertFalse(actualItem.isCriticalUpdate)
    }
}
