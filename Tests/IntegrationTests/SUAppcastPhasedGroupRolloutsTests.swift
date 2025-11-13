//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastPhasedGroupRolloutsTests: XCTestCase {
    // MARK: - Helper Methods
    
    private func loadTestData() throws -> Data {
        let testURL = Bundle.module.url(forResource: "testappcast_phasedRollout", withExtension: "xml")!
        return try Data(contentsOf: testURL)
    }
    
    private func createDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        return dateFormatter
    }
    
    private func createAppcast(testData: Data, hostVersion: String, versionComparator: SUStandardVersionComparator) throws -> SUAppcast {
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
        return try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
    }
    
    // MARK: - Host Version 1.0 Tests (Minimum Autoupdate Version)
    // Because 3.0 has minimum autoupdate version of 2.0, we should be offered 2.0
    
    func testHost1_NoGroup() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            // Test no group
            let group: NSNumber? = nil
            let currentDate = Date()
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(1, supportedAppcast.items.count)
            XCTAssertEqual("2.0", supportedAppcast.items[0].versionString)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost1_NilGroupAheadOfPubDate() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            // Test 0 group with current date (way ahead of pubDate)
            let group: NSNumber? = nil
            let currentDate = Date()
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(1, supportedAppcast.items.count)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost1_Group6AheadOfPubDate() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            // Test 6th group with current date (way ahead of pubDate)
            let group = 6 as NSNumber
            let currentDate = Date()
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(1, supportedAppcast.items.count)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost1_Group0ThreeDaysBeforeRollout() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            let dateFormatter = createDateFormatter()
            let currentDate = dateFormatter.date(from: "Wed, 23 Jul 2014 15:20:11 +0000")!
            
            // Test group 0 with current date 3 days before rollout
            // No update should be found
            let group = 0 as NSNumber
            
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(0, supportedAppcast.items.count)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost1_Group6ThreeDaysBeforeRollout() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            let dateFormatter = createDateFormatter()
            let currentDate = dateFormatter.date(from: "Wed, 23 Jul 2014 15:20:11 +0000")!
            
            // Test group 6 with current date 3 days before rollout
            // No update should be found still
            let group = 6 as NSNumber
            
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(0, supportedAppcast.items.count)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost1_Group0AfterRollout() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            let dateFormatter = createDateFormatter()
            let currentDate = dateFormatter.date(from: "Mon, 28 Jul 2014 15:20:11 +0000")!
            
            // Test group 0 with current date 2 days after rollout
            let group = 0 as NSNumber
            
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(1, supportedAppcast.items.count)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost1_Group1AfterRollout() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            let dateFormatter = createDateFormatter()
            let currentDate = dateFormatter.date(from: "Mon, 28 Jul 2014 15:20:11 +0000")!
            
            // Test group 1 with current date 3 days after rollout
            let group = 1 as NSNumber
            
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(1, supportedAppcast.items.count)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost1_Group2AfterRollout() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            let dateFormatter = createDateFormatter()
            let currentDate = dateFormatter.date(from: "Mon, 28 Jul 2014 15:20:11 +0000")!
            
            // Test group 2 with current date 3 days after rollout
            let group = 2 as NSNumber
            
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(1, supportedAppcast.items.count)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost1_Group3AfterRollout() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            let dateFormatter = createDateFormatter()
            let currentDate = dateFormatter.date(from: "Mon, 28 Jul 2014 15:20:11 +0000")!
            
            // Test group 3 with current date 3 days after rollout
            let group = 3 as NSNumber
            
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(0, supportedAppcast.items.count)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost1_Group6AfterRollout() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "1.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            let dateFormatter = createDateFormatter()
            let currentDate = dateFormatter.date(from: "Mon, 28 Jul 2014 15:20:11 +0000")!
            
            // Test group 6 with current date 3 days after rollout
            let group = 6 as NSNumber
            
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(0, supportedAppcast.items.count)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    // MARK: - Host Version 2.0 Tests (Critical Updates)
    // Test critical updates which ignore phased rollouts
    
    func testHost2Critical_NoGroup() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "2.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            // Test no group
            let group: NSNumber? = nil
            let currentDate = Date()
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(2, supportedAppcast.items.count)
            XCTAssertEqual("3.0", supportedAppcast.items[0].versionString)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost2Critical_Group0ThreeDaysBeforeRollout() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "2.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            let dateFormatter = createDateFormatter()
            let currentDate = dateFormatter.date(from: "Wed, 23 Jul 2014 15:20:11 +0000")!
            
            // Test group 0 with current date 3 days before rollout
            let group = 0 as NSNumber
            
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(1, supportedAppcast.items.count)
            XCTAssertEqual("3.0", supportedAppcast.items[0].versionString)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testHost2Critical_Group6AfterRollout() {
        do {
            let testData = try loadTestData()
            let versionComparator = SUStandardVersionComparator()
            let hostVersion = "2.0"
            let appcast = try createAppcast(testData: testData, hostVersion: hostVersion, versionComparator: versionComparator)
            
            let dateFormatter = createDateFormatter()
            let currentDate = dateFormatter.date(from: "Mon, 28 Jul 2014 15:20:11 +0000")!
            
            // Test group 6 with current date 3 days after rollout
            let group = 6 as NSNumber
            
            let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(appcast, phasedUpdateGroup: group, skippedUpdate: nil, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator, testOSVersion: true, testMinimumAutoupdateVersion: true)
            
            XCTAssertEqual(1, supportedAppcast.items.count)
            XCTAssertEqual("3.0", supportedAppcast.items[0].versionString)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
