//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastParserNamespacesTest: XCTestCase {
    func testNamespaces() {
        let testFile = Bundle.module.path(forResource: "testnamespaces", ofType: "xml")!
        let testData = NSData(contentsOfFile: testFile)!

        do {
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: "1.0", applicationVersionComparator: SUStandardVersionComparator.default, standardVersionComparator: SUStandardVersionComparator.default)
            
            let appcast = try SUAppcast(xmlData: testData as Data, relativeTo: nil, stateResolver: stateResolver)
            let items = appcast.items

            XCTAssertEqual(2, items.count)

            XCTAssertEqual("Version 2.0", items[1].title)
            XCTAssertEqual("desc", items[1].itemDescription)
            XCTAssertNotNil(items[0].releaseNotesURL)
            XCTAssertEqual("https://sparkle-project.org/#works", items[0].releaseNotesURL!.absoluteString)
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
