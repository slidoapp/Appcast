//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_deltaUpdates: SUAppcastItemBaseTests {
    func test_deltaUpdate_inheritsParentMetadataAndResolvedState() throws {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SURSSElement.Title] = "Acme 3.0"
        dictionary[SUAppcastElement.Version] = "3.0"
        dictionary[SUAppcastElement.ShortVersionString] = "3"
        dictionary[SURSSElement.PubDate] = "Sat, 26 Jul 2014 15:20:11 +0000"
        dictionary[SUAppcastElement.MinimumAutoupdateVersion] = "2.0"
        dictionary[SUAppcastElement.CriticalUpdate] = SUAppcast.AttributesDictionary()

        var deltaEnclosure = SUAppcast.AttributesDictionary()
        deltaEnclosure[SURSSAttribute.URL] = "https://example.com/Acme-3.0-from-1.0.delta"
        deltaEnclosure[SURSSAttribute.Length] = "1234"
        deltaEnclosure[SUAppcastAttribute.DeltaFrom] = "1.0"
        dictionary[SUAppcastElement.Deltas] = [deltaEnclosure]

        let comparator = SUStandardVersionComparator.default
        let stateResolver = SPUAppcastItemStateResolver(
            hostVersion: "1.0",
            applicationVersionComparator: comparator,
            standardVersionComparator: comparator
        )
        let parentItem = try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: stateResolver,
            resolvedState: nil
        )

        let deltaItem = try XCTUnwrap(parentItem.deltaUpdates["1.0"])

        XCTAssertEqual(deltaItem.title, parentItem.title)
        XCTAssertEqual(deltaItem.versionString, parentItem.versionString)
        XCTAssertEqual(deltaItem.displayVersionString, parentItem.displayVersionString)
        XCTAssertEqual(deltaItem.dateString, parentItem.dateString)
        XCTAssertEqual(deltaItem.minimumAutoupdateVersion, parentItem.minimumAutoupdateVersion)
        XCTAssertEqual(deltaItem._state, parentItem._state)
        XCTAssertTrue(deltaItem.isDeltaUpdate)
        XCTAssertEqual(deltaItem.fileURL?.absoluteString, "https://example.com/Acme-3.0-from-1.0.delta")
    }

    func test_deltaUpdate_doesNotRecursivelyCopySiblingDeltas() throws {
        var dictionary = createBasicAppcastItemDictionary()

        var deltaEnclosure = SUAppcast.AttributesDictionary()
        deltaEnclosure[SURSSAttribute.URL] = "https://example.com/Acme-1.0.delta"
        deltaEnclosure[SUAppcastAttribute.DeltaFrom] = "1.0"
        dictionary[SUAppcastElement.Deltas] = [deltaEnclosure]

        let parentItem = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)
        let deltaItem = try XCTUnwrap(parentItem.deltaUpdates["1.0"])

        XCTAssertTrue(deltaItem.deltaUpdates.isEmpty)
    }

    func test_deltaUpdate_emptyDeltaFromValue_isRetained() throws {
        var dictionary = createBasicAppcastItemDictionary()

        var deltaEnclosure = SUAppcast.AttributesDictionary()
        deltaEnclosure[SURSSAttribute.URL] = "https://example.com/Acme-empty.delta"
        deltaEnclosure[SUAppcastAttribute.DeltaFrom] = ""
        dictionary[SUAppcastElement.Deltas] = [deltaEnclosure]

        let parentItem = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)

        XCTAssertNotNil(parentItem.deltaUpdates[""])
    }
}
