//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastChannelTests: XCTestCase {
    func testChannelsAndMacOSReleases() {
        let testURL = Bundle.module.url(forResource: "testappcast_channels", withExtension: "xml")!
        
        do {
            let testData = try Data(contentsOf: testURL)
            
            let versionComparator = SUStandardVersionComparator.default
            let hostVersion = "1.0"
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
            
            let appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
            XCTAssertEqual(6, appcast.items.count)
            
            do {
                let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: ["beta", "nightly"])
                XCTAssertEqual(4, filteredAppcast.items.count)
                
                XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
                XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
                XCTAssertEqual("4.0", filteredAppcast.items[2].versionString)
                XCTAssertEqual("5.0", filteredAppcast.items[3].versionString)
            }
            
            do {
                let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: [])
                XCTAssertEqual(2, filteredAppcast.items.count)
                XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
                XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
            }
            
            do {
                let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: ["beta"])
                XCTAssertEqual(3, filteredAppcast.items.count)
                XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
                XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
                XCTAssertEqual("4.0", filteredAppcast.items[2].versionString)
            }
            
            do {
                let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: ["nightly"])
                XCTAssertEqual(3, filteredAppcast.items.count)
                XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
                XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
                XCTAssertEqual("5.0", filteredAppcast.items[2].versionString)
            }
            
            do {
                let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: ["madeup"])
                XCTAssertEqual("2.0", filteredAppcast.items[0].versionString)
                XCTAssertEqual("3.0", filteredAppcast.items[1].versionString)
                XCTAssertEqual(2, filteredAppcast.items.count)
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
