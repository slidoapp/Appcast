//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_minimumRequirements: SUAppcastItemBaseTests {
    private let comparator = SUStandardVersionComparator.default

    func test_minimumUpdateVersion_isParsedAndResolvedAgainstHostVersion() throws {
        XCTAssertTrue(try makeItem(hostVersion: "1.0", minimumUpdateVersion: nil).minimumUpdateVersionIsOK)
        XCTAssertTrue(try makeItem(hostVersion: "1.0", minimumUpdateVersion: "").minimumUpdateVersionIsOK)
        XCTAssertTrue(try makeItem(hostVersion: "1.0", minimumUpdateVersion: "0.9").minimumUpdateVersionIsOK)
        XCTAssertTrue(try makeItem(hostVersion: "1.0", minimumUpdateVersion: "1.0").minimumUpdateVersionIsOK)

        let unsupportedItem = try makeItem(hostVersion: "1.0", minimumUpdateVersion: "1.1")
        XCTAssertEqual(unsupportedItem.minimumUpdateVersion, "1.1")
        XCTAssertFalse(unsupportedItem.minimumUpdateVersionIsOK)
    }

    func test_filterAppcast_excludesItemThatRequiresNewerHostVersion() throws {
        let supportedItem = try makeItem(hostVersion: "1.0", minimumUpdateVersion: "1.0")
        let unsupportedItem = try makeItem(hostVersion: "1.0", minimumUpdateVersion: "1.1")
        let appcast = SUAppcast(items: [unsupportedItem, supportedItem])

        let filteredAppcast = SUAppcastDriver.filterAppcast(appcast, forMacOSAndAllowedChannels: [])

        XCTAssertEqual(filteredAppcast.items, [supportedItem])
    }

    func test_hardwareRequirements_areSplitOnCommasAndWhitespaceAndLowercased() throws {
        let item = try makeItem(hardwareRequirements: " ARM64,other\tfuture ")

        XCTAssertEqual(item.hardwareRequirements, ["arm64", "other", "future"])
    }

    func test_appcastXML_parsesMinimumUpdateAndHardwareRequirementsElements() throws {
        let xml = """
        <?xml version="1.0" encoding="utf-8"?>
        <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
          <channel>
            <item>
              <sparkle:version>2.0</sparkle:version>
              <sparkle:minimumUpdateVersion>1.1</sparkle:minimumUpdateVersion>
              <sparkle:hardwareRequirements>ARM64,other</sparkle:hardwareRequirements>
              <enclosure url="https://example.com/Acme.zip" />
            </item>
          </channel>
        </rss>
        """

        let appcast = try SUAppcast(
            xmlData: Data(xml.utf8),
            relativeTo: nil,
            stateResolver: makeResolver(hostVersion: "1.0")
        )
        let item = try XCTUnwrap(appcast.items.first)

        XCTAssertEqual(item.minimumUpdateVersion, "1.1")
        XCTAssertFalse(item.minimumUpdateVersionIsOK)
        XCTAssertEqual(item.hardwareRequirements, ["arm64", "other"])
    }

    func test_arm64Requirement_nativeIntelIsRejected() {
        let resolver = makeResolver(hostVersion: "1.0")

        XCTAssertFalse(resolver.isArm64HardwareRequirementOK(
            [SUAppcastElement.HardwareRequirementARM64],
            minimumSystemVersion: nil,
            architecture: .intelNative
        ))
        XCTAssertTrue(resolver.isArm64HardwareRequirementOK(
            [SUAppcastElement.HardwareRequirementARM64],
            minimumSystemVersion: nil,
            architecture: .intelTranslated
        ))
        XCTAssertTrue(resolver.isArm64HardwareRequirementOK(
            [SUAppcastElement.HardwareRequirementARM64],
            minimumSystemVersion: nil,
            architecture: .arm64OrCompatible
        ))
    }

    func test_minimumMacOS27Requirement_impliesArm64Requirement() {
        let resolver = makeResolver(hostVersion: "1.0")

        XCTAssertFalse(resolver.isArm64HardwareRequirementOK(
            [],
            minimumSystemVersion: "27.0",
            architecture: .intelNative
        ))
        XCTAssertTrue(resolver.isArm64HardwareRequirementOK(
            [],
            minimumSystemVersion: "26.9",
            architecture: .intelNative
        ))
    }

    func test_filterSupportedAppcast_appliesHardwareRequirementWithSystemRequirements() throws {
        let state = SPUAppcastItemState(
            withMajorUpgrade: false,
            criticalUpdate: false,
            informationalUpdate: false,
            minimumOperatingSystemVersionIsOK: true,
            maximumOperatingSystemVersionIsOK: true,
            arm64HardwareRequirementIsOK: false
        )
        let item = try SUAppcastItem(
            dictionary: createBasicAppcastItemDictionary(),
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: state
        )
        let appcast = SUAppcast(items: [item])

        let filteredAppcast = SUAppcastDriver.filterSupportedAppcast(
            appcast,
            phasedUpdateGroup: nil,
            skippedUpdate: nil,
            currentDate: Date(),
            hostVersion: "1.0",
            versionComparator: comparator,
            testOSVersion: true,
            testMinimumAutoupdateVersion: false
        )
        let unfilteredAppcast = SUAppcastDriver.filterSupportedAppcast(
            appcast,
            phasedUpdateGroup: nil,
            skippedUpdate: nil,
            currentDate: Date(),
            hostVersion: "1.0",
            versionComparator: comparator,
            testOSVersion: false,
            testMinimumAutoupdateVersion: false
        )

        XCTAssertTrue(filteredAppcast.items.isEmpty)
        XCTAssertEqual(unfilteredAppcast.items, [item])
    }

    private func makeItem(
        hostVersion: String = "1.0",
        minimumUpdateVersion: String? = nil,
        hardwareRequirements: String? = nil
    ) throws -> SUAppcastItem {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SUAppcastElement.MinimumUpdateVersion] = minimumUpdateVersion
        dictionary[SUAppcastElement.HardwareRequirements] = hardwareRequirements

        return try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: makeResolver(hostVersion: hostVersion),
            resolvedState: nil
        )
    }

    private func makeResolver(hostVersion: String) -> SPUAppcastItemStateResolver {
        SPUAppcastItemStateResolver(
            hostVersion: hostVersion,
            applicationVersionComparator: comparator,
            standardVersionComparator: comparator
        )
    }
}
