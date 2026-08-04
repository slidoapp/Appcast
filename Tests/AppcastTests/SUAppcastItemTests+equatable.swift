//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_equatable: SUAppcastItemBaseTests {
    private struct EquatableCustomProperty: Sendable, Equatable {
        let value: Int
    }

    func test_equality_itemParsedFromXML_isReflexive() throws {
        let xml = """
        <?xml version="1.0" encoding="utf-8"?>
        <rss version="2.0"
             xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"
             xmlns:custom="https://example.com/appcast">
          <channel>
            <item>
              <sparkle:version>1.0</sparkle:version>
              <custom:metadata>custom value</custom:metadata>
              <enclosure url="https://example.com/Acme.zip" />
            </item>
          </channel>
        </rss>
        """
        let appcast = try SUAppcast(xmlData: Data(xml.utf8), relativeTo: nil, stateResolver: nil)
        let item = try XCTUnwrap(appcast.items.first)

        XCTAssertEqual(item, item)
    }

    func test_equality_equatableCustomProperties_areReflexiveAndEquivalent() throws {
        let firstItem = try createAppcastItem(customProperty: EquatableCustomProperty(value: 42))
        let secondItem = try createAppcastItem(customProperty: EquatableCustomProperty(value: 42))

        XCTAssertEqual(firstItem, firstItem)
        XCTAssertEqual(firstItem, secondItem)
    }

    func test_equality_differentEquatableCustomProperties_areNotEqual() throws {
        let firstItem = try createAppcastItem(customProperty: EquatableCustomProperty(value: 1))
        let secondItem = try createAppcastItem(customProperty: EquatableCustomProperty(value: 2))

        XCTAssertNotEqual(firstItem, secondItem)
    }

    func test_equality_copiedItemWithCustomProperty_isEqual() throws {
        let originalItem = try createAppcastItem(customProperty: EquatableCustomProperty(value: 42))
        let copiedItem = originalItem

        XCTAssertEqual(originalItem, copiedItem)
    }

    func test_equality_nestedCustomProperties_areReflexiveAndEquivalent() throws {
        let nestedProperty = ["payload": EquatableCustomProperty(value: 42)]
        let firstItem = try createAppcastItem(customProperty: nestedProperty)
        let secondItem = try createAppcastItem(customProperty: nestedProperty)

        XCTAssertEqual(firstItem, firstItem)
        XCTAssertEqual(firstItem, secondItem)
    }

    func test_equality_explicitNilCustomProperties_areEqual() throws {
        let nilProperty: SUAppcastItemPropertyValue = Optional<String>.none
        let firstItem = try createAppcastItem(customProperty: nilProperty)
        let secondItem = try createAppcastItem(customProperty: nilProperty)

        XCTAssertEqual(firstItem, secondItem)
    }

    func test_equality_numericallyEqualPropertiesWithDifferentTypes_areNotEqual() throws {
        let integerItem = try createAppcastItem(customProperty: Int(42))
        let integer64Item = try createAppcastItem(customProperty: Int64(42))

        XCTAssertNotEqual(integerItem, integer64Item)
    }

    func test_collection_canFindItemContainingCustomProperty() throws {
        let item = try createAppcastItem(customProperty: EquatableCustomProperty(value: 42))
        let items = [item]

        XCTAssertTrue(items.contains(item))
    }

    private func createAppcastItem(customProperty: SUAppcastItemPropertyValue) throws -> SUAppcastItem {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary["custom:metadata"] = customProperty

        return try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil
        )
    }
}
