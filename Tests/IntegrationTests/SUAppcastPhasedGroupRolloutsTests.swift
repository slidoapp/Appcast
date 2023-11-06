//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastPhasedGroupRolloutsTests: XCTestCase {
    func testPhasedGroupRollouts() {
        let testURL = Bundle.module.url(forResource: "testappcast_phasedRollout", withExtension: "xml")!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            // Because 3.0 has minimum autoupdate version of 2.0, we should be offered 2.0
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                do {
                    // Test no group
                    let group: NSNumber? = nil
                    let currentDate = Date()
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                    
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    XCTAssertEqual("2.0", supportedAppcast.items[0].versionString)
                }
                
                do {
                    // Test 0 group with current date (way ahead of pubDate)
                    let group: NSNumber? = nil
                    let currentDate = Date()
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                    
                    XCTAssertEqual(1, supportedAppcast.items.count)
                }
                
                do {
                    // Test 6th group with current date (way ahead of pubDate)
                    let group = 6 as NSNumber
                    let currentDate = Date()
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                    
                    XCTAssertEqual(1, supportedAppcast.items.count)
                }
                
                do {
                    let currentDate = dateFormatter.date(from: "Wed, 23 Jul 2014 15:20:11 +0000")!
                    
                    do {
                        // Test group 0 with current date 3 days before rollout
                        // No update should be found
                        let group = 0 as NSNumber
                        
                        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                        
                        XCTAssertEqual(0, supportedAppcast.items.count)
                    }
                    
                    do {
                        // Test group 6 with current date 3 days before rollout
                        // No update should be found still
                        let group = 6 as NSNumber
                        
                        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                        
                        XCTAssertEqual(0, supportedAppcast.items.count)
                    }
                }
                
                do {
                    let currentDate = dateFormatter.date(from: "Mon, 28 Jul 2014 15:20:11 +0000")!
                    
                    do {
                        // Test group 0 with current date 2 days after rollout
                        let group = 0 as NSNumber
                        
                        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                        
                        XCTAssertEqual(1, supportedAppcast.items.count)
                    }
                    
                    do {
                        // Test group 1 with current date 3 days after rollout
                        let group = 1 as NSNumber
                        
                        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                        
                        XCTAssertEqual(1, supportedAppcast.items.count)
                    }
                    
                    do {
                        // Test group 2 with current date 3 days after rollout
                        let group = 2 as NSNumber
                        
                        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                        
                        XCTAssertEqual(1, supportedAppcast.items.count)
                    }
                    
                    do {
                        // Test group 3 with current date 3 days after rollout
                        let group = 3 as NSNumber
                        
                        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                        
                        XCTAssertEqual(0, supportedAppcast.items.count)
                    }
                    
                    do {
                        // Test group 6 with current date 3 days after rollout
                        let group = 6 as NSNumber
                        
                        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                        
                        XCTAssertEqual(0, supportedAppcast.items.count)
                    }
                }
                
                // Test critical updates which ignore phased rollouts
                do {
                    let hostVersion = "2.0"
                    
                    let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                    let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                    
                    do {
                        // Test no group
                        let group: NSNumber? = nil
                        let currentDate = Date()
                        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                        
                        XCTAssertEqual(2, supportedAppcast.items.count)
                        XCTAssertEqual("3.0", supportedAppcast.items[0].versionString)
                    }
                    
                    do {
                        let currentDate = dateFormatter.date(from: "Wed, 23 Jul 2014 15:20:11 +0000")!
                        
                        do {
                            // Test group 0 with current date 3 days before rollout
                            let group = 0 as NSNumber
                            
                            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                            
                            XCTAssertEqual(1, supportedAppcast.items.count)
                            XCTAssertEqual("3.0", supportedAppcast.items[0].versionString)
                        }
                    }
                    
                    do {
                        let currentDate = dateFormatter.date(from: "Mon, 28 Jul 2014 15:20:11 +0000")!
                        
                        do {
                            // Test group 6 with current date 3 days after rollout
                            let group = 6 as NSNumber
                            
                            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                            
                            XCTAssertEqual(1, supportedAppcast.items.count)
                            XCTAssertEqual("3.0", supportedAppcast.items[0].versionString)
                        }
                    }
                }
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
