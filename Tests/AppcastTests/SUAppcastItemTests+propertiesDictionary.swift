//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_propertiesDictionary: SUAppcastItemBaseTests {
    func test_propertiesDictionary_preservesCustomExtensionValue() throws {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary["custom:metadata"] = "custom value"

        let item = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)

        XCTAssertEqual(item.propertiesDictionary["custom:metadata"] as? String, "custom value")
        XCTAssertEqual(item.propertiesDictionary[SUAppcastElement.Version] as? String, "1.0.0")
    }

    func test_appcastXML_preservesCustomExtensionElement() throws {
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

        XCTAssertEqual(item.propertiesDictionary["custom:metadata"] as? String, "custom value")
    }

    func test_equality_samePropertiesBaseURLAndState_isEqual() throws {
        let dictionary = createBasicAppcastItemDictionary()
        let comparator = SUStandardVersionComparator.default
        let resolver = SPUAppcastItemStateResolver(
            hostVersion: "1.0",
            applicationVersionComparator: comparator,
            standardVersionComparator: comparator
        )

        let firstItem = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: resolver, resolvedState: nil)
        let secondItem = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: resolver, resolvedState: nil)

        XCTAssertEqual(firstItem, secondItem)
    }

    func test_equality_sameRelativePropertiesWithDifferentBaseURLs_isNotEqual() throws {
        var dictionary = createBasicAppcastItemDictionary()
        var enclosure = dictionary[SURSSElement.Enclosure] as! SUAppcast.AttributesDictionary
        enclosure[SURSSAttribute.URL] = "Acme.zip"
        dictionary[SURSSElement.Enclosure] = enclosure

        let firstItem = try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: URL(string: "https://example.com/releases/")!,
            stateResolver: nil,
            resolvedState: nil
        )
        let secondItem = try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: URL(string: "https://cdn.example.com/releases/")!,
            stateResolver: nil,
            resolvedState: nil
        )

        XCTAssertNotEqual(firstItem, secondItem)
    }
}
