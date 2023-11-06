//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastDangerousLinksTests: XCTestCase {
    func test_appcastWithNonSecureLinks_failsParsing() throws {
        // Arrange
        let testFile = Bundle.module.url(forResource: "test-dangerous-link", withExtension: "xml")!
        let testData = try Data(contentsOf: testFile)
        
        let baseURL: URL? = nil
        let stateResolver = SPUAppcastItemStateResolver(hostVersion: "1.0", applicationVersionComparator: SUStandardVersionComparator.default, standardVersionComparator: SUStandardVersionComparator.default)
        
        // Act & Assert
        XCTAssertThrowsError(try SUAppcast(xmlData: testData as Data, relativeTo: baseURL, stateResolver: stateResolver)) { (error: Error) in
            switch error as? AppcastItemError {
            case .invalidInfoLink(let message):
                XCTAssertEqual("Info link is not using secure HTTPS scheme.", message)
            default:
                XCTFail("Appcast with insecure links must throw the `AppcastItemError.invalidInfoLink` error.")
            }
        }
    }
}
