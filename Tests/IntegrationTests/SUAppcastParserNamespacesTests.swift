//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastParserNamespacesTest: XCTestCase {
    var appcast = SUAppcast.empty
    
    override func setUpWithError() throws {
        guard let testURL = Bundle.module.url(forResource: "testnamespaces", withExtension: "xml") else {
            fatalError("Resource file is not bundled in integration test.")
        }
        
        let testData = try Data(contentsOf: testURL)
        
        let versionComparator = SUStandardVersionComparator.default
        let hostVersion = "1.0"
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
        
        self.appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
    }
    
    func test_init_appcastWithCustomNamespaceName_count() {
        // Arrange
        let actualCount = self.appcast.items.count

        // Assert
        XCTAssertEqual(2, actualCount)
    }
    
    func test_init_appcastWithCustomNamespaceName_version2() {
        // Arrange
        let actualItemVersion2 = self.appcast.items[1]

        // Assert
        XCTAssertEqual("Version 2.0", actualItemVersion2.title)
        XCTAssertEqual("desc", actualItemVersion2.itemDescription)
        XCTAssertNil(actualItemVersion2.releaseNotesURL)
    }
    
    func test_init_appcastWithCustomNamespaceName_version3() {
        // Arrange
        let actualItemVersion3 = self.appcast.items[0]

        // Assert
        XCTAssertEqual("Version 3.0", actualItemVersion3.title)
        XCTAssertNil(actualItemVersion3.itemDescription)
        XCTAssertNotNil(actualItemVersion3.releaseNotesURL)
        XCTAssertEqual("https://sparkle-project.org/#works", actualItemVersion3.releaseNotesURL?.absoluteString)
    }
}
