//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_versionString: SUAppcastItemBaseTests {
    func test_versionString_enclosureAttributeTakesPrecedenceOverElementAndFileName() throws {
        var dictionary = makeDictionary(fileURL: "https://example.com/Acme_1.0.zip")
        dictionary[SUAppcastElement.Version] = "2.0"
        var enclosure = dictionary[SURSSElement.Enclosure] as! SUAppcast.AttributesDictionary
        enclosure[SUAppcastAttribute.Version] = "3.0"
        dictionary[SURSSElement.Enclosure] = enclosure

        let item = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)

        XCTAssertEqual(item.versionString, "3.0")
    }

    func test_versionString_elementTakesPrecedenceOverFileName() throws {
        var dictionary = makeDictionary(fileURL: "https://example.com/Acme_1.0.zip")
        dictionary[SUAppcastElement.Version] = "2.0"

        let item = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)

        XCTAssertEqual(item.versionString, "2.0")
    }

    func test_versionString_missingExplicitVersion_isDeducedFromFileName() throws {
        let dictionary = makeDictionary(fileURL: "https://example.com/Acme_1.2.3.zip")

        let item = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)

        XCTAssertEqual(item.versionString, "1.2.3")
        XCTAssertEqual(item.displayVersionString, "1.2.3")
    }

    func test_versionString_missingExplicitVersionAndFileNameSeparator_throws() {
        let dictionary = makeDictionary(fileURL: "https://example.com/Acme.zip")

        XCTAssertThrowsError(try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)) { error in
            guard case AppcastItemError.missingVersion = error else {
                return XCTFail("Expected missingVersion, got \(error)")
            }
        }
    }

    private func makeDictionary(fileURL: String) -> SUAppcastItemProperties {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary.removeValue(forKey: SUAppcastElement.Version)
        var enclosure = dictionary[SURSSElement.Enclosure] as! SUAppcast.AttributesDictionary
        enclosure[SURSSAttribute.URL] = fileURL
        dictionary[SURSSElement.Enclosure] = enclosure
        return dictionary
    }
}
