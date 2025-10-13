//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastInformationalUpdateTests: XCTestCase {
    func testInformationalUpdatesFromVersion1_0() {
        let testURL = Bundle.module.url(forResource: "testappcast_info_updates", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            
            // Test informational updates from version 1.0
            do {
                let hostVersion = "1.0"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertFalse(appcast.items[0].isInformationOnlyUpdate)
                XCTAssertFalse(appcast.items[1].isInformationOnlyUpdate)
                XCTAssertTrue(appcast.items[2].isInformationOnlyUpdate)
                XCTAssertTrue(appcast.items[3].isInformationOnlyUpdate)
                
                // Test delta updates inheriting informational only updates
                do {
                    let deltaUpdate = appcast.items[2].deltaUpdates["2.0"]
                    XCTAssertEqual(true, deltaUpdate?.isInformationOnlyUpdate)
                }
            }
            
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testInformationalUpdatesFromVersion2_3() {
        let testURL = Bundle.module.url(forResource: "testappcast_info_updates", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            
            // Test informational updates from version 2.3
            do {
                let hostVersion = "2.3"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertFalse(appcast.items[1].isInformationOnlyUpdate)
            }
            
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testInformationalUpdatesFromVersion2_4() {
        let testURL = Bundle.module.url(forResource: "testappcast_info_updates", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            
            // Test informational updates from version 2.4
            do {
                let hostVersion = "2.4"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertTrue(appcast.items[1].isInformationOnlyUpdate)
            }
            
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testInformationalUpdatesFromVersion2_5() {
        let testURL = Bundle.module.url(forResource: "testappcast_info_updates", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            
            // Test informational updates from version 2.5
            do {
                let hostVersion = "2.5"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertTrue(appcast.items[1].isInformationOnlyUpdate)
            }
            
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testInformationalUpdatesFromVersion2_6() {
        let testURL = Bundle.module.url(forResource: "testappcast_info_updates", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            
            // Test informational updates from version 2.6
            do {
                let hostVersion = "2.6"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertFalse(appcast.items[1].isInformationOnlyUpdate)
            }
            
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testInformationalUpdatesFromVersion0_5() {
        let testURL = Bundle.module.url(forResource: "testappcast_info_updates", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            
            // Test informational updates from version 0.5
            do {
                let hostVersion = "0.5"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertFalse(appcast.items[1].isInformationOnlyUpdate)
            }
            
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testInformationalUpdatesFromVersion0_4() {
        let testURL = Bundle.module.url(forResource: "testappcast_info_updates", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            
            // Test informational updates from version 0.4
            do {
                let hostVersion = "0.4"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertTrue(appcast.items[1].isInformationOnlyUpdate)
            }
            
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testInformationalUpdatesFromVersion0_0() {
        let testURL = Bundle.module.url(forResource: "testappcast_info_updates", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            
            // Test informational updates from version 0.0
            do {
                let hostVersion = "0.0"
                let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
                
                let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
                
                XCTAssertTrue(appcast.items[1].isInformationOnlyUpdate)
            }
            
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
