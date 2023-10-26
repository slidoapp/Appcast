//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastParserTest: XCTestCase {
    func testParseAppcast() {
        let testURL = Bundle.module.url(forResource: "testappcast", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            let hostVersion = "1.0"
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
            
            let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
            let items = appcast.items

            XCTAssertEqual(4, items.count)

            XCTAssertEqual("Version 2.0", items[0].title)
            XCTAssertEqual("desc", items[0].itemDescription)
            XCTAssertEqual("plain-text", items[0].itemDescriptionFormat)
            XCTAssertEqual("Sat, 26 Jul 2014 15:20:11 +0000", items[0].dateString)
            XCTAssertTrue(items[0].isCriticalUpdate)
            XCTAssertEqual(items[0].versionString, "2.0")

            // This is the best release matching our system version
            XCTAssertEqual("Version 3.0", items[1].title)
            XCTAssertEqual("desc3", items[1].itemDescription)
            XCTAssertEqual("html", items[1].itemDescriptionFormat)
            XCTAssertNil(items[1].dateString)
            XCTAssertTrue(items[1].isCriticalUpdate)
            XCTAssertEqual(items[1].phasedRolloutInterval, 86400)
            XCTAssertEqual(items[1].versionString, "3.0")

            XCTAssertEqual("Version 4.0", items[2].title)
            XCTAssertNil(items[2].itemDescription)
            XCTAssertEqual("Sat, 26 Jul 2014 15:20:13 +0000", items[2].dateString)
            XCTAssertFalse(items[2].isCriticalUpdate)

            XCTAssertEqual("Version 5.0", items[3].title)
            XCTAssertNil(items[3].itemDescription)
            XCTAssertNil(items[3].dateString)
            XCTAssertFalse(items[3].isCriticalUpdate)

            // Test best appcast item & a delta update item
            let currentDate = Date()
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
            
            let supportedAppcastItems = supportedAppcast.items
            
            var deltaItem: SUAppcastItem?
            let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcastItems, getDeltaItem: &deltaItem, withHostVersion: "1.0", comparator: SUStandardVersionComparator())

            XCTAssertIdentical(bestAppcastItem, items[1])
            XCTAssertEqual(deltaItem!.fileURL!.lastPathComponent, "3.0_from_1.0.patch")
            XCTAssertEqual(deltaItem!.versionString, "3.0")

            // Test latest delta update item available
            var latestDeltaItem: SUAppcastItem?
            SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcastItems, getDeltaItem: &latestDeltaItem, withHostVersion: "2.0", comparator: SUStandardVersionComparator())

            XCTAssertEqual(latestDeltaItem!.fileURL!.lastPathComponent, "3.0_from_2.0.patch")

            // Test a delta item that does not exist
            var nonexistantDeltaItem: SUAppcastItem?
            SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcastItems, getDeltaItem: &nonexistantDeltaItem, withHostVersion: "2.1", comparator: SUStandardVersionComparator())

            XCTAssertNil(nonexistantDeltaItem)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
