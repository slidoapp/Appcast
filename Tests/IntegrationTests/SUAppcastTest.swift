//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastTest: XCTestCase {
    func testMinimumAutoupdateVersionAdvancedSkipping() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersionSkipping", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            do {
                // Test appcast without a filter
                
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertEqual(5, appcast.items.count)
            }
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 3.0, and 4.0 has minimum autoupdate version of 4.0, we should be offered 2.0
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                
                XCTAssertEqual(1, supportedAppcast.items.count)
                
                let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                
                XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
            }
            
            // Allow minimum autoupdate version to fail and only skip major version "3.0"
            // This should skip all 3.x versions, but not 4.x versions nor 2.x versions
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: nil)
                
                let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
            
                XCTAssertEqual(3, supportedAppcast.items.count)
                
                let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                
                XCTAssertEqual(bestAppcastItem?.versionString, "4.1")
            }
            
            // Allow minimum autoupdate version to pass and only skip major version "3.0"
            // This should only return back the latest minor version available
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: nil)
                
                let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
                XCTAssertEqual(1, supportedAppcast.items.count)
                
                let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                
                XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
            }
            
            // Allow minimum autoupdate version to fail and only skip major version "4.0"
            // This should skip all 3.x versions and 4.x versions but not 2.x versions
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "4.0", majorSubreleaseVersion: nil)
                
                let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
            
                XCTAssertEqual(1, supportedAppcast.items.count)
                
                let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                
                XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testMinimumAutoupdateVersionIgnoringSkipping() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersionSkipping2", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
            
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                // Allow minimum autoupdate version to fail and only skip major version "3.0" with no subrelease version
                // This should skip all 3.x versions except for 3.9 which ignores skipped upgrades below 3.5, but not 4.x versions nor 2.x versions
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(4, supportedAppcast.items.count)
                    
                    XCTAssertEqual(supportedAppcast.items[0].versionString, "4.1")
                    XCTAssertEqual(supportedAppcast.items[1].versionString, "4.0")
                    XCTAssertEqual(supportedAppcast.items[2].versionString, "3.9")
                    XCTAssertEqual(supportedAppcast.items[3].versionString, "2.0")
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "4.1")
                }
                
                // Allow minimum autoupdate version to fail and only skip major version "3.0" with subrelease version 3.4
                // This should skip all 3.x versions except for 3.9 which ignores skipped upgrades below 3.5, but not 4.x versions nor 2.x versions
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.4", majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(4, supportedAppcast.items.count)
                    
                    XCTAssertEqual(supportedAppcast.items[0].versionString, "4.1")
                    XCTAssertEqual(supportedAppcast.items[1].versionString, "4.0")
                    XCTAssertEqual(supportedAppcast.items[2].versionString, "3.9")
                    XCTAssertEqual(supportedAppcast.items[3].versionString, "2.0")
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "4.1")
                }
                
                // Allow minimum autoupdate version to fail and only skip major version "3.0" with subrelease version 3.5
                // This should skip all 3.x versions, but not 4.x versions nor 2.x versions
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: "3.5")
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(3, supportedAppcast.items.count)
                    
                    XCTAssertEqual(supportedAppcast.items[0].versionString, "4.1")
                    XCTAssertEqual(supportedAppcast.items[1].versionString, "4.0")
                    XCTAssertEqual(supportedAppcast.items[2].versionString, "2.0")
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "4.1")
                }
                
                // Allow minimum autoupdate version to fail and only skip major version "3.0" with subrelease version 3.5.1
                // This should skip all 3.x versions, but not 4.x versions nor 2.x versions
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: "3.5.1")
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(3, supportedAppcast.items.count)
                    
                    XCTAssertEqual(supportedAppcast.items[0].versionString, "4.1")
                    XCTAssertEqual(supportedAppcast.items[1].versionString, "4.0")
                    XCTAssertEqual(supportedAppcast.items[2].versionString, "2.0")
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "4.1")
                }
                
                // Allow minimum autoupdate version to fail and only skip major version "4.0" with subrelease version 4.0
                // This should skip all 3.x versions and 4.x versions, but not 2.x versions
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "4.0", majorSubreleaseVersion: "4.0")
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    XCTAssertEqual(supportedAppcast.items[0].versionString, "2.0")
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
                }
                
                // Allow minimum autoupdate version to fail and only skip major version "4.0" with subrelease version 4.0, and skip minor version 2.1
                // This should skip everything
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.1", majorVersion: "4.0", majorSubreleaseVersion: "4.0")
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(0, supportedAppcast.items.count)
                }
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
