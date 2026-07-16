//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_phasedRolloutInterval: SUAppcastItemBaseTests {
    func test_phasedRolloutInterval_missingValue_isNil() throws {
        let item = try makeItem(phasedRolloutInterval: nil)

        XCTAssertNil(item.phasedRolloutInterval)
    }

    func test_phasedRolloutInterval_validInteger_isParsed() throws {
        let item = try makeItem(phasedRolloutInterval: "86400")

        XCTAssertEqual(item.phasedRolloutInterval, 86_400)
    }

    func test_phasedRolloutInterval_invalidInteger_matchesSparkleIntegerValueFallback() throws {
        let item = try makeItem(phasedRolloutInterval: "invalid")

        XCTAssertEqual(item.phasedRolloutInterval, 0)
    }

    func test_phasedRolloutInterval_numericPrefix_matchesNSStringParsing() throws {
        let item = try makeItem(phasedRolloutInterval: "86400 seconds")

        XCTAssertEqual(item.phasedRolloutInterval, 86_400)
    }

    private func makeItem(phasedRolloutInterval: String?) throws -> SUAppcastItem {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SUAppcastElement.PhasedRolloutInterval] = phasedRolloutInterval

        return try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil
        )
    }
}
