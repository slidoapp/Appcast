//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastDriverUnitTests: SUAppcastItemBaseTests {
    private let versionComparator = SUStandardVersionComparator.default

    func test_containsSkippedUpdate_majorVersionWithoutIgnoreThreshold_skipsItem() throws {
        let item = try makeItem(version: "3.9", minimumAutoupdateVersion: "3.0")
        let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: nil)

        let containsSkippedUpdate = SUAppcastDriver.containsSkippedUpdate(
            item: item,
            skippedUpdate: skippedUpdate,
            hostPassesSkippedMajorVersion: false,
            versionComparator: versionComparator
        )

        XCTAssertTrue(containsSkippedUpdate)
    }

    func test_containsSkippedUpdate_majorVersionBelowMinimumAutoupdateVersion_doesNotSkipItem() throws {
        let item = try makeItem(version: "4.0", minimumAutoupdateVersion: "4.0")
        let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: nil)

        let containsSkippedUpdate = SUAppcastDriver.containsSkippedUpdate(
            item: item,
            skippedUpdate: skippedUpdate,
            hostPassesSkippedMajorVersion: false,
            versionComparator: versionComparator
        )

        XCTAssertFalse(containsSkippedUpdate)
    }

    func test_containsSkippedUpdate_ignoreThresholdWithoutSkippedSubrelease_doesNotSkipItem() throws {
        let item = try makeItem(version: "3.9", minimumAutoupdateVersion: "3.0", ignoreSkippedUpgradesBelowVersion: "3.5")
        let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: nil)

        let containsSkippedUpdate = SUAppcastDriver.containsSkippedUpdate(
            item: item,
            skippedUpdate: skippedUpdate,
            hostPassesSkippedMajorVersion: false,
            versionComparator: versionComparator
        )

        XCTAssertFalse(containsSkippedUpdate)
    }

    func test_containsSkippedUpdate_skippedSubreleaseBelowIgnoreThreshold_doesNotSkipItem() throws {
        let item = try makeItem(version: "3.9", minimumAutoupdateVersion: "3.0", ignoreSkippedUpgradesBelowVersion: "3.5")
        let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: "3.4")

        let containsSkippedUpdate = SUAppcastDriver.containsSkippedUpdate(
            item: item,
            skippedUpdate: skippedUpdate,
            hostPassesSkippedMajorVersion: false,
            versionComparator: versionComparator
        )

        XCTAssertFalse(containsSkippedUpdate)
    }

    func test_containsSkippedUpdate_skippedSubreleaseAtIgnoreThreshold_skipsItem() throws {
        let item = try makeItem(version: "3.9", minimumAutoupdateVersion: "3.0", ignoreSkippedUpgradesBelowVersion: "3.5")
        let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: "3.5")

        let containsSkippedUpdate = SUAppcastDriver.containsSkippedUpdate(
            item: item,
            skippedUpdate: skippedUpdate,
            hostPassesSkippedMajorVersion: false,
            versionComparator: versionComparator
        )

        XCTAssertTrue(containsSkippedUpdate)
    }

    func test_containsSkippedUpdate_hostAlreadyPassesSkippedMajorVersion_doesNotSkipItem() throws {
        let item = try makeItem(version: "3.9", minimumAutoupdateVersion: "3.0")
        let skippedUpdate = SPUSkippedUpdate(minorVersion: nil, majorVersion: "3.0", majorSubreleaseVersion: nil)

        let containsSkippedUpdate = SUAppcastDriver.containsSkippedUpdate(
            item: item,
            skippedUpdate: skippedUpdate,
            hostPassesSkippedMajorVersion: true,
            versionComparator: versionComparator
        )

        XCTAssertFalse(containsSkippedUpdate)
    }

    func test_containsSkippedUpdate_minorVersionOnlySkipsSameOrOlderItems() throws {
        let olderItem = try makeItem(version: "2.0")
        let newerItem = try makeItem(version: "3.0")
        let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.1", majorVersion: nil, majorSubreleaseVersion: nil)

        XCTAssertTrue(SUAppcastDriver.containsSkippedUpdate(
            item: olderItem,
            skippedUpdate: skippedUpdate,
            hostPassesSkippedMajorVersion: true,
            versionComparator: versionComparator
        ))
        XCTAssertFalse(SUAppcastDriver.containsSkippedUpdate(
            item: newerItem,
            skippedUpdate: skippedUpdate,
            hostPassesSkippedMajorVersion: true,
            versionComparator: versionComparator
        ))
    }

    func test_itemIsReadyForPhasedRollout_negativeGroupUsesUnsignedIntegerConversion() throws {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SURSSElement.PubDate] = "Sat, 26 Jul 2014 15:20:11 +0000"
        dictionary[SUAppcastElement.PhasedRolloutInterval] = "86400"
        let item = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)
        let currentDate = try XCTUnwrap(item.date).addingTimeInterval(86_400 * 10)

        XCTAssertFalse(SUAppcastDriver.itemIsReadyForPhasedRollout(
            item,
            phasedUpdateGroup: NSNumber(value: -1),
            currentDate: currentDate,
            hostVersion: "1.0",
            versionComparator: versionComparator
        ))
    }

    func test_bestItem_inoutOverloadReturnsDeltaForSelectedItem() throws {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SUAppcastElement.Version] = "2.0"

        var deltaEnclosure = SUAppcast.AttributesDictionary()
        deltaEnclosure[SURSSAttribute.URL] = "https://example.com/Acme-2.0-from-1.0.delta"
        deltaEnclosure[SUAppcastAttribute.DeltaFrom] = "1.0"
        dictionary[SUAppcastElement.Deltas] = [deltaEnclosure]

        let item = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)
        var deltaItem: SUAppcastItem?
        let selectedItem = SUAppcastDriver.bestItem(
            fromAppcastItems: [item],
            getDeltaItem: &deltaItem,
            withHostVersion: "1.0",
            comparator: versionComparator
        )

        XCTAssertEqual(selectedItem?.versionString, "2.0")
        XCTAssertEqual(deltaItem?.fileURL?.absoluteString, "https://example.com/Acme-2.0-from-1.0.delta")
    }

    func test_filteringAppcast_preservesSigningValidationStatus() throws {
        let item = try makeItem(version: "2.0")
        let appcast = SUAppcast(items: [item], signingValidationStatus: .failed)

        let supportedAppcast = SUAppcastDriver.filterSupportedAppcast(
            appcast,
            phasedUpdateGroup: nil,
            skippedUpdate: nil,
            currentDate: Date(),
            hostVersion: "1.0",
            versionComparator: versionComparator,
            testOSVersion: false,
            testMinimumAutoupdateVersion: false
        )
        let channelFilteredAppcast = SUAppcastDriver.filterAppcast(
            appcast,
            forMacOSAndAllowedChannels: []
        )

        XCTAssertEqual(supportedAppcast.signingValidationStatus, .failed)
        XCTAssertEqual(channelFilteredAppcast.signingValidationStatus, .failed)
    }

    func test_filterSupportedAppcast_emptyHostVersionStillAppliesSkippedUpdate() throws {
        let item = try makeItem(version: "2.0")
        let appcast = SUAppcast(items: [item])
        let skippedUpdate = SPUSkippedUpdate(minorVersion: "2.0", majorVersion: nil, majorSubreleaseVersion: nil)

        let filteredAppcast = SUAppcastDriver.filterSupportedAppcast(
            appcast,
            phasedUpdateGroup: nil,
            skippedUpdate: skippedUpdate,
            currentDate: Date(),
            hostVersion: "",
            versionComparator: versionComparator,
            testOSVersion: false,
            testMinimumAutoupdateVersion: false
        )

        XCTAssertTrue(filteredAppcast.items.isEmpty)
    }

    private func makeItem(
        version: String,
        minimumAutoupdateVersion: String? = nil,
        ignoreSkippedUpgradesBelowVersion: String? = nil
    ) throws -> SUAppcastItem {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SUAppcastElement.Version] = version
        dictionary[SUAppcastElement.MinimumAutoupdateVersion] = minimumAutoupdateVersion
        dictionary[SUAppcastElement.IgnoreSkippedUpgradesBelowVersion] = ignoreSkippedUpgradesBelowVersion

        return try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)
    }
}
