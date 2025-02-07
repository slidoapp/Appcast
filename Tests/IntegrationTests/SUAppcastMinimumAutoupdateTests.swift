//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastMinimumAutoupdateTests: XCTestCase {
    func testMinimumAutoupdateVersion() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            do {
                // Test appcast without a filter
                
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertEqual(2, appcast.items.count)
            }
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 2.0, we should be offered 2.0
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                
                XCTAssertEqual(1, supportedAppcast.items.count)
                
                let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                
                XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
            }
            
            // We should be offered 3.0 if host version is 2.0
            do {
                let hostVersion = "2.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                
                XCTAssertEqual(2, supportedAppcast.items.count)
                
                let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                
                XCTAssertEqual(bestAppcastItem?.versionString, "3.0")
            }
            
            // We should be offered 3.0 if host version is 2.5
            do {
                let hostVersion = "2.5"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                
                XCTAssertEqual(2, supportedAppcast.items.count)
                
                let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                
                XCTAssertEqual(bestAppcastItem?.versionString, "3.0")
            }
            
            // Because 3.0 has minimum autoupdate version of 2.0, we would be be offered 2.0, but not if it has been skipped
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                // There should be no items if 2.0 is skipped from 1.0 and 3.0 fails minimum autoupdate version
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.0", majorVersion: nil, majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                
                    XCTAssertEqual(0, supportedAppcast.items.count)
                }
                
                // Try again but allowing minimum autoupdate version to fail
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.0", majorVersion: nil, majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "3.0")
                }
                
                // Allow minimum autoupdate version to fail and only skip 3.0
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
                }
                
                // Allow minimum autoupdate version to fail skipping both 2.0 and 3.0
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.0", majorVersion: "3.0", majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(0, supportedAppcast.items.count)
                }
                
                // Allow minimum autoupdate version to fail and only skip "2.5"
                // This should implicitly only skip 2.0
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.5", majorVersion: nil, majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "3.0")
                }
                
                // This should not skip anything but require passing minimum autoupdate version
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "1.5", majorVersion: nil, majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
                }
                
                // This should not skip anything but allow failing minimum autoupdate version
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "1.5", majorVersion: nil, majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(2, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "3.0")
                }
                
                // This should not skip anything but require passing minimum autoupdate version
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "1.5", majorVersion: "1.0", majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
                }
                
                // This should not skip anything but allow failing minimum autoupdate version
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "1.5", majorVersion: "1.0", majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(2, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "3.0")
                }
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
