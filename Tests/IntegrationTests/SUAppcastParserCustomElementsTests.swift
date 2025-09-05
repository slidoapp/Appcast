//
// Copyright © 2016 Sparkle Project. All rights reserved.
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
        XCTAssertEqual("http://www.slido.com/sparkle", slidoNamespace)
    }
    
    /// Test scenario: This is the best release matching our system version.
    func test_items_item1_bestReleaseMatchingSystemVersion() {
        // Arrange
        let actualItem = self.appcast.items[1]
        
        // Assert
        XCTAssertEqual("Version 3.0", actualItem.title)
        
        let customElm = actualItem.extensions["slido:powerpoint"]
        XCTAssertEqual("16.0", customElm?.value)
    }
}
