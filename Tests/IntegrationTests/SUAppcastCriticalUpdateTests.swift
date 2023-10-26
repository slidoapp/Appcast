//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastCriticalUpdateTests: XCTestCase {
    func testCriticalUpdateVersion() {
        let testURL = Bundle.module.url(forResource: "testappcast", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            
            // If critical update version is 1.5 and host version is 1.0, update should be marked critical
            do {
                let hostVersion = "1.0"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                XCTAssertTrue(appcast.items[0].isCriticalUpdate)
            }
            
            // If critical update version is 1.5 and host version is 1.5, update should not be marked critical
            do {
                let hostVersion = "1.5"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                XCTAssertFalse(appcast.items[0].isCriticalUpdate)
            }
            
            // If critical update version is 1.5 and host version is 1.6, update should not be marked critical
            do {
                let hostVersion = "1.6"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                XCTAssertFalse(appcast.items[0].isCriticalUpdate)
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
