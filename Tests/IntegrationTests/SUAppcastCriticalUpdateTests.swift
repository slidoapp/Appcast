//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastCriticalUpdateTests: XCTestCase {
    let versionComparator = SUStandardVersionComparator.default
    var testData = Data()
    
    override func setUpWithError() throws {
        guard let testURL = Bundle.module.url(forResource: "testappcast", withExtension: "xml") else {
            fatalError("Resource file is not bundled in integration test.")
        }
        
        self.testData = try Data(contentsOf: testURL)
    }
    
    /// If critical update version is 1.5 and host version is 1.0, update should be marked critical/
    func test_isCriticalUpdate_hostVersionIsLowerThanCriticalUpdateRelase() throws {
        // Arrange
        let hostVersion = "1.0"
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: self.versionComparator, standardVersionComparator: self.versionComparator)
        
        // Act
        let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
        let actualItem = appcast.items[0]
        
        // Assert
        XCTAssertTrue(actualItem.isCriticalUpdate)
    }

    /// If critical update version is 1.5 and host version is 1.5, update should not be marked critical/
    func test_isCriticalUpdate_hostVersionIsSameAsCriticalUpdateRelase() throws {
        // Arrange
        let hostVersion = "1.5"
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: self.versionComparator, standardVersionComparator: self.versionComparator)
        
        // Act
        let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
        let actualItem = appcast.items[0]
        
        // Assert
        XCTAssertFalse(actualItem.isCriticalUpdate)
    }
    
    /// If critical update version is 1.5 and host version is 1.6, update should not be marked critical/
    func test_isCriticalUpdate_hostVersionIsHigherThanCriticalUpdateRelase() throws {
        // Arrange
        let hostVersion = "1.6"
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: self.versionComparator, standardVersionComparator: self.versionComparator)
        
        // Act
        let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
        let actualItem = appcast.items[0]
        
        // Assert
        XCTAssertFalse(actualItem.isCriticalUpdate)
    }
}
