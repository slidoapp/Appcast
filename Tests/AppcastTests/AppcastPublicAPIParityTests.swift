//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import Appcast
import XCTest

final class AppcastPublicAPIParityTests: XCTestCase {
    func test_signingSkippedUpdateAndDeltaSelectionAPIs_arePubliclyUsable() throws {
        let deltaEnclosure: [String: String] = [
            "url": "https://example.com/Acme-2.0-from-1.0.delta",
            "sparkle:deltaFrom": "1.0",
        ]
        let enclosure: [String: String] = [
            "url": "https://example.com/Acme.zip",
            "length": "100",
        ]
        let properties: SUAppcastItemProperties = [
            "sparkle:version": "2.0",
            "enclosure": enclosure,
            "sparkle:deltas": [deltaEnclosure],
        ]
        let item = try SUAppcastItem(
            dictionary: properties,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil,
            signingValidationStatus: .succeeded
        )
        var deltaItem: SUAppcastItem?
        let selectedItem = SUAppcastDriver.bestItem(
            fromAppcastItems: [item],
            getDeltaItem: &deltaItem,
            withHostVersion: "1.0",
            comparator: SUStandardVersionComparator.default
        )
        let skippedUpdate = SPUSkippedUpdate(
            minorVersion: "2.0",
            majorVersion: nil,
            majorSubreleaseVersion: nil
        )
        let signatures = SUSignatures(ed: nil, dsa: "AQID")

        XCTAssertEqual(item.signingValidationStatus, .succeeded)
        XCTAssertEqual(selectedItem?.versionString, "2.0")
        XCTAssertNotNil(deltaItem)
        XCTAssertEqual(skippedUpdate.minorVersion, "2.0")
        XCTAssertEqual(signatures.dsaSignatureStatus, .present)
    }
}
