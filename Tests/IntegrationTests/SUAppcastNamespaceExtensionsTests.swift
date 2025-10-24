//
// Copyright © 2025 Cisco Systems, Inc. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastNamespaceExtensionsTests: XCTestCase {
    var appcast = SUAppcast.empty
    
    override func setUpWithError() throws {
        guard let testURL = Bundle.module.url(forResource: "test-namespace-extensions", withExtension: "xml") else {
            fatalError("Resource file is not bundled in integration test.")
        }
        
        let testData = try Data(contentsOf: testURL)
        
        let versionComparator = SUStandardVersionComparator.default
        let hostVersion = "1.0"
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
        
        self.appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
    }
    
    func test_init_appcastWithNamespaceExtensions_count() {
        // Arrange
        let actualCount = self.appcast.items.count

        // Assert
        XCTAssertEqual(2, actualCount)
    }
    
    func test_init_appcastWithNamespaceExtensions_countOfNamespaceDefinitions() {
        // Arrange
        let namespaces = self.appcast.namespaces

        // Assert
        XCTAssertEqual(2, namespaces.count)
    }
    
    func test_init_appcastWithNamespaceExtensions_listOfNamespaceDefinitions() {
        // Arrange
        let namespaces = self.appcast.namespaces
        let sparkleNamespaceValue = namespaces["sparkle"]
        let acmeNamespaceValue = namespaces["acme"]

        // Assert
        XCTAssertEqual("http://www.andymatuschak.org/xml-namespaces/sparkle", sparkleNamespaceValue)
        XCTAssertEqual("https://example.org/acme-namespace", acmeNamespaceValue)
    }
}
