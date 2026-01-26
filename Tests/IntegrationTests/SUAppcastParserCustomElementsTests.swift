//
// Copyright © 2025 Cisco Systems, Inc. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastParserCustomElementsTests: XCTestCase {
    var appcast = SUAppcast.empty
    
    override func setUpWithError() throws {
        guard let testURL = Bundle.module.url(forResource: "testappcast_slido", withExtension: "xml") else {
            fatalError("Resource file is not bundled in integration test.")
        }
        
        let testData = try Data(contentsOf: testURL)
        
        let versionComparator = SUStandardVersionComparator.default
        let hostVersion = "1.0"
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: hostVersion, applicationVersionComparator: versionComparator, standardVersionComparator: versionComparator)
        
        self.appcast = try SUAppcast(xmlData: testData, relativeTo: nil, stateResolver: stateResolver)
    }
    
    /// Test scenario: Appcast will list the namespaces defined on the `<rss>` element.
    func test_namespaces_list() {
        // Arrange
        let namespaces = self.appcast.namespaces
        
        // Act
        let sparkleNamepsace = namespaces["sparkle"]
        let slidoNamespace = namespaces["slido"]
        
        // Assert
        XCTAssertEqual("http://www.andymatuschak.org/xml-namespaces/sparkle", sparkleNamepsace)
        XCTAssertEqual("https://www.slido.com/sparkle", slidoNamespace)
    }
    
    /// Test scenario: This is the best release matching our system version.
    func test_item0_slidoExtensionData() {
        // Arrange
        let actualItem = self.appcast.items[0]

        // Assert
        XCTAssertEqual("Version 1.0", actualItem.title)

        // Test slido:ppam element with attributes
        guard let ppamElm = actualItem.extensions["slido:ppam"] else {
            XCTFail("slido:ppam element should be present")
            return
        }

        XCTAssertEqual("https://example.org/SlidoPowerPointAddin.zip", ppamElm.attributes["url"])
        XCTAssertEqual("...", ppamElm.attributes["signature"])

        // Test slido:powerpoint element
        let powerpointElm = actualItem.extensions["slido:powerpoint"]
        XCTAssertEqual("16.0", powerpointElm?.value)
    }
}
