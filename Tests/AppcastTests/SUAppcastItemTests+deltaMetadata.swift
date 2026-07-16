//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_deltaMetadata: SUAppcastItemBaseTests {
    func test_deltaFromSparkleExecutableSize_positiveInteger_isParsed() throws {
        let item = try makeItem(executableSize: "12345")

        XCTAssertEqual(item.deltaFromSparkleExecutableSize, 12345)
    }

    func test_deltaFromSparkleExecutableSize_numericPrefix_matchesNSStringParsing() throws {
        let item = try makeItem(executableSize: "12345 bytes")

        XCTAssertEqual(item.deltaFromSparkleExecutableSize, 12345)
    }

    func test_deltaFromSparkleExecutableSize_nonPositiveOrInvalidValue_isIgnored() throws {
        XCTAssertNil(try makeItem(executableSize: "0").deltaFromSparkleExecutableSize)
        XCTAssertNil(try makeItem(executableSize: "-1").deltaFromSparkleExecutableSize)
        XCTAssertNil(try makeItem(executableSize: "large").deltaFromSparkleExecutableSize)
    }

    func test_deltaFromSparkleLocales_invalidOrEmptyLocales_areIgnored() throws {
        let item = try makeItem(locales: "en,,fr.lproj,../de,es/ES,sk")

        XCTAssertEqual(item.deltaFromSparkleLocales, ["en", "sk"])
    }

    func test_deltaFromSparkleLocales_moreThanLimit_onlyProcessesFirstFifteenEntries() throws {
        let locales = (1...16).map { "locale\($0)" }.joined(separator: ",")
        let item = try makeItem(locales: locales)

        XCTAssertEqual(item.deltaFromSparkleLocales?.count, 15)
        XCTAssertTrue(item.deltaFromSparkleLocales?.contains("locale15") == true)
        XCTAssertFalse(item.deltaFromSparkleLocales?.contains("locale16") == true)
    }

    private func makeItem(executableSize: String? = nil, locales: String? = nil) throws -> SUAppcastItem {
        var dictionary = createBasicAppcastItemDictionary()
        var enclosure = dictionary[SURSSElement.Enclosure] as! SUAppcast.AttributesDictionary
        enclosure[SUAppcastAttribute.DeltaFromSparkleExecutableSize] = executableSize
        enclosure[SUAppcastAttribute.DeltaFromSparkleLocales] = locales
        dictionary[SURSSElement.Enclosure] = enclosure

        return try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)
    }
}
