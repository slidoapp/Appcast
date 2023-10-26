//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastDangerousLinksTests: XCTestCase {
    func testDangerousLink() {
        let testFile = Bundle.module.path(forResource: "test-dangerous-link", ofType: "xml")!
        let testData = NSData(contentsOfFile: testFile)!
        
        do {
            let baseURL: URL? = nil
            
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: "1.0", applicationVersionComparator: SUStandardVersionComparator.default, standardVersionComparator: SUStandardVersionComparator.default)
            
            let _ = try SUAppcast(xmlData: testData as Data, relativeTo: baseURL, stateResolver: stateResolver)
            
            XCTFail("Appcast creation should fail when encountering dangerous link")
        } catch let err as NSError {
            NSLog("Expected error: %@", err)
            XCTAssertNotNil(err)
        }
    }
}
