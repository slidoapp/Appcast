//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastDriverTests: XCTestCase {
    let versionComparator = SUStandardVersionComparator.default
    let hostVersion = "1.0"
    var appcast = SUAppcast.empty
    
    override func setUpWithError() throws {
        guard let testURL = Bundle.module.url(forResource: "testappcast", withExtension: "xml") else {
            fatalError("Resource file is not bundled in integration test.")
        }
        
        let testData = try Data(contentsOf: testURL)
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
        
        self.appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
    }
    
    func getAppcastWithDeltaUpdates() -> SUAppcast {
        guard let testURL = Bundle.module.url(forResource: "testappcast_delta", withExtension: "xml") else {
            fatalError("Resource file is not bundled in integration test.")
        }
        
        do {
            let testData = try Data(contentsOf: testURL)
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
            
            return try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
        }
        catch {
            fatalError("Failed to parse resource testappcast_delta.xml file")
        }
    }
    
    func test_filterSupportedAppcast() {
        // Arrange
        // Test best appcast item & a delta update item
        let currentDate = Date()
        
        // Act
        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: nil, currentDate: currentDate, hostVersion: self.hostVersion, versionComparator: self.versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)

        // Assert
        XCTAssertEqual(2, supportedAppcast.items.count)
    }
    
    /// Test latest delta update item available
    func test_bestItem_returnsBestApplicableUpdateItem() {
        // Arrange
        let hostVersion = "2.0"
        let appcast = self.getAppcastWithDeltaUpdates()
        let supportedAppcastItems = appcast.items
        var deltaItem: SUAppcastItem?
        
        // Act
        let actualBestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcastItems, getDeltaItem: &deltaItem, withHostVersion: hostVersion, comparator: self.versionComparator)

        // Arrange
        XCTAssertIdentical(actualBestAppcastItem, supportedAppcastItems[1])
    }
    
    /// Test latest delta update item available
    func test_bestItem_deltaUpdateForVersion1() {
        // Arrange
        let hostVersion = "1.0"
        let appcast = self.getAppcastWithDeltaUpdates()
        let supportedAppcastItems = appcast.items
        
        // Act
        var actualDeltaItem: SUAppcastItem?
        _ = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcastItems, getDeltaItem: &actualDeltaItem, withHostVersion: hostVersion, comparator: self.versionComparator)

        // Arrange
        XCTAssertEqual(actualDeltaItem?.fileURL?.lastPathComponent, "3.0_from_1.0.patch")
        XCTAssertEqual(actualDeltaItem?.versionString, "3.0")
    }
    
    /// Test latest delta update item available
    func test_bestItem_deltaUpdateForVersion2() {
        // Arrange
        let hostVersion = "2.0"
        let appcast = self.getAppcastWithDeltaUpdates()
        let supportedAppcastItems = appcast.items
        
        // Act
        var actualDeltaItem: SUAppcastItem?
        _ = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcastItems, getDeltaItem: &actualDeltaItem, withHostVersion: hostVersion, comparator: self.versionComparator)

        // Arrange
        XCTAssertEqual(actualDeltaItem?.fileURL?.lastPathComponent, "3.0_from_2.0.patch")
        XCTAssertEqual(actualDeltaItem?.versionString, "3.0")
    }
    
    /// Test a delta item that does not exist
    func test_bestItem_nonExistingDeltaUpdate() {
        // Arrange
        let hostVersion = "2.1"
        let appcast = self.getAppcastWithDeltaUpdates()
        let supportedAppcastItems = appcast.items
        
        // Act
        var nonexistantDeltaItem: SUAppcastItem?
        _ = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcastItems, getDeltaItem: &nonexistantDeltaItem, withHostVersion: hostVersion, comparator: self.versionComparator)

        // Arrange
        XCTAssertNil(nonexistantDeltaItem)
    }
}
