//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastLinkTests: XCTestCase {
    func testLinks() throws {
        // Arrange
        let testFile = Bundle.module.path(forResource: "test-links", ofType: "xml")!
        let testData = NSData(contentsOfFile: testFile)!
    
        let baseURL: URL? = nil
        
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: "1.0", applicationVersionComparator: SUStandardVersionComparator.default, standardVersionComparator: SUStandardVersionComparator.default)
        
        // Act
        let appcast = try SUAppcast(xmlData: testData as Data, relativeTo: baseURL, stateResolver: stateResolver)
        let items = appcast.items
        
        // Assert
        XCTAssertEqual(1, items.count)
        
        XCTAssertEqual("https://sparkle-project.org/notes/relnote-3.0.txt", items[0].releaseNotesURL?.absoluteString)
        XCTAssertEqual("https://sparkle-project.org/fullnotes.txt", items[0].fullReleaseNotesURL?.absoluteString)
        XCTAssertEqual("https://sparkle-project.org", items[0].infoURL?.absoluteString)
        XCTAssertEqual("https://sparkle-project.org/release-3.0.zip", items[0].fileURL?.absoluteString)
    }

    func testRelativeURLs() {
        let testFile = Bundle.module.path(forResource: "test-relative-urls", ofType: "xml")!
        let testData = NSData(contentsOfFile: testFile)!

        do {
            let baseURL = URL(string: "https://fake.sparkle-project.org/updates/index.xml")!
            
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: "1.0", applicationVersionComparator: SUStandardVersionComparator.default, standardVersionComparator: SUStandardVersionComparator.default)
            
            let appcast = try SUAppcast(xmlData: testData as Data, relativeTo: baseURL, stateResolver: stateResolver)
            let items = appcast.items

            XCTAssertEqual(4, items.count)

            XCTAssertEqual("https://fake.sparkle-project.org/updates/release-3.0.zip", items[0].fileURL?.absoluteString)
            XCTAssertEqual("https://fake.sparkle-project.org/updates/notes/relnote-3.0.txt", items[0].releaseNotesURL?.absoluteString)

            XCTAssertEqual("https://fake.sparkle-project.org/info/info-2.0.txt", items[1].infoURL?.absoluteString)
            
            XCTAssertEqual("https://fake.sparkle-project.org/updates/notes/fullnotes.txt", items[2].fullReleaseNotesURL?.absoluteString)
            
            // If a different base URL is in the feed, we should respect the base URL in the feed
            XCTAssertEqual("https://sparkle-project.org/releasenotes.html", items[3].fullReleaseNotesURL?.absoluteString)

        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
