//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastMinimumAutoupdateTests: XCTestCase {
    func testAppcastWithoutFilter() {
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
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testMinimumAutoupdateVersionFromHost1_0() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
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
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testMinimumAutoupdateVersionFromHost2_0() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
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
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testMinimumAutoupdateVersionFromHost2_5() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
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
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testSkippedUpdate2_0WithMinimumAutoupdateVersionRequired() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
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
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testSkippedUpdate2_0WithMinimumAutoupdateVersionAllowedToFail() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 2.0, we would be be offered 2.0, but not if it has been skipped
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                // Try again but allowing minimum autoupdate version to fail
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.0", majorVersion: nil, majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "3.0")
                }
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testSkippedUpdate3_0OnlyWithMinimumAutoupdateVersionAllowedToFail() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 2.0, we would be be offered 2.0, but not if it has been skipped
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                // Allow minimum autoupdate version to fail and only skip 3.0
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
                }
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testSkippedUpdateBoth2_0And3_0WithMinimumAutoupdateVersionAllowedToFail() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 2.0, we would be be offered 2.0, but not if it has been skipped
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                // Allow minimum autoupdate version to fail skipping both 2.0 and 3.0
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.0", majorVersion: "3.0", majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(0, supportedAppcast.items.count)
                }
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testSkippedUpdate2_5ImplicitlySkips2_0() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 2.0, we would be be offered 2.0, but not if it has been skipped
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                // Allow minimum autoupdate version to fail and only skip "2.5"
                // This should implicitly only skip 2.0
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.5", majorVersion: nil, majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: false)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "3.0")
                }
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testSkippedUpdate1_5NoSkipWithMinimumAutoupdateVersionRequired() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 2.0, we would be be offered 2.0, but not if it has been skipped
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                // This should not skip anything but require passing minimum autoupdate version
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "1.5", majorVersion: nil, majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
                }
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testSkippedUpdate1_5NoSkipWithMinimumAutoupdateVersionAllowedToFail() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 2.0, we would be be offered 2.0, but not if it has been skipped
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                // This should not skip anything but allow failing minimum autoupdate version
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "1.5", majorVersion: nil, majorSubreleaseVersion: nil)
                    
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
    
    func testSkippedUpdate1_5And1_0NoSkipWithMinimumAutoupdateVersionRequired() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 2.0, we would be be offered 2.0, but not if it has been skipped
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                // This should not skip anything but require passing minimum autoupdate version
                do {
                    let skippedUpdate = SPUSkippedUpdate(minorVersion: "1.5", majorVersion: "1.0", majorSubreleaseVersion: nil)
                    
                    let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: nil, skippedUpdate: skippedUpdate, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
                
                    XCTAssertEqual(1, supportedAppcast.items.count)
                    
                    let bestAppcastItem = SUAppcastDriver.bestItem(fromAppcastItems: supportedAppcast.items, getDeltaItem: nil, withHostVersion: hostVersion, comparator: versionComparator)
                    
                    XCTAssertEqual(bestAppcastItem?.versionString, "2.0")
                }
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testSkippedUpdate1_5And1_0NoSkipWithMinimumAutoupdateVersionAllowedToFail() {
        let testURL = Bundle.module.url(forResource: "testappcast_minimumAutoupdateVersion", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator()
            
            let currentDate = Date()
            // Because 3.0 has minimum autoupdate version of 2.0, we would be be offered 2.0, but not if it has been skipped
            do {
                let hostVersion = "1.0"
                
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
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
