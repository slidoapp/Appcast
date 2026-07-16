//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_description: SUAppcastItemBaseTests {
    func test_itemDescriptionFormat_supportedFormat_isNormalizedToLowercase() throws {
        let item = try makeItem(description: ["content": "Changes", "format": "MARKDOWN"])

        XCTAssertEqual(item.itemDescription, "Changes")
        XCTAssertEqual(item.itemDescriptionFormat, "markdown")
    }

    func test_itemDescriptionFormat_unknownFormat_defaultsToHTML() throws {
        let item = try makeItem(description: ["content": "Changes", "format": "rich-text"])

        XCTAssertEqual(item.itemDescriptionFormat, "html")
    }

    func test_itemDescriptionFormat_missingFormat_defaultsToHTML() throws {
        let item = try makeItem(description: ["content": "Changes"])

        XCTAssertEqual(item.itemDescriptionFormat, "html")
    }

    func test_itemDescriptionFormat_missingContent_isNil() throws {
        let item = try makeItem(description: ["format": "plain-text"])

        XCTAssertNil(item.itemDescription)
        XCTAssertNil(item.itemDescriptionFormat)
    }

    func test_itemDescription_legacyString_defaultsFormatToHTML() throws {
        let item = try makeItem(description: "Legacy changes")

        XCTAssertEqual(item.itemDescription, "Legacy changes")
        XCTAssertEqual(item.itemDescriptionFormat, "html")
    }

    private func makeItem(description: any Sendable) throws -> SUAppcastItem {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SURSSElement.Description] = description
        return try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)
    }
}
