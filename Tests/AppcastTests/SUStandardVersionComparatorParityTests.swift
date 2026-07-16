//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUStandardVersionComparatorParityTests: XCTestCase {
    private let comparator = SUStandardVersionComparator.default

    func test_compareVersion_numericVersions_matchesSparkleOrdering() {
        assertAscending("1.0", "1.1")
        assertEqual("1.0", "1.0")
        assertDescending("2.0", "1.1")
        assertDescending("0.1", "0.0.1")
        assertAscending("0.1", "0.1.2")
        assertEqual("1.0", "1.0.0")
        assertEqual("1.0.0", "1.0")
    }

    func test_compareVersion_commitSHAs_ignoresSuffixAfterDash() {
        assertAscending("1.5.5-335d3e2", "1.5.6-b252311")
        assertEqual("1.5.5-335d3e2", "1.5.5-a655360")
        assertDescending("1.5.6-b252311", "1.5.5-335d3e2")
        assertEqual("1.5-335d3e2", "1.5.0-335d3e2")
        assertEqual("1.5.0-335d3e2", "1.5-335d3e2")
    }

    func test_compareVersion_prereleases_matchesSparkleOrdering() {
        assertAscending("1.5.5", "1.5.6a1")
        assertAscending("1.1.0b1", "1.1.0b2")
        assertAscending("1.1.1b2", "1.1.2b1")
        assertAscending("1.1.1b2", "1.1.2a1")
        assertAscending("1.0a1", "1.0b1")
        assertAscending("1.0b1", "1.0")
        assertAscending("0.9", "1.0a1")
        assertAscending("1.0b", "1.0b2")
        assertAscending("1.0b10", "1.0b11")
        assertAscending("1.0b9", "1.0b10")
        assertAscending("1.0rc", "1.0")
        assertAscending("1.0b", "1.0")
        assertAscending("1.0pre1", "1.0")
        assertEqual("1.0pre1", "1.0.0pre1")
        assertEqual("1.0.0pre1", "1.0pre1")
    }

    func test_compareVersion_versionsWithBuildNumbers_matchesSparkleOrdering() {
        assertAscending("1.0 (1234)", "1.0 (1235)")
        assertAscending("1.0b1 (1234)", "1.0 (1234)")
        assertAscending("1.0b5 (1234)", "1.0b5 (1235)")
        assertAscending("1.0b5 (1234)", "1.0.1b5 (1234)")
        assertAscending("1.0.1b5 (1234)", "1.0.1b6 (1234)")
        assertAscending("2.0.0.2429", "2.0.0.2430")
        assertAscending("1.1.1.1818", "2.0.0.2430")
        assertAscending("3.3 (5847)", "3.3.1b1 (5902)")
        assertEqual("3.3 (5847)", "3.3.0 (5847)")
        assertEqual("3.3.0 (5847)", "3.3 (5847)")
        assertEqual("1.1.1.1818", "1.1.1.1818.0")
        assertEqual("1.1.1.1818.0", "1.1.1.1818")
        assertEqual("3.3b1 (5902)", "3.3.0b1 (5902)")
        assertEqual("3.3.0b1 (5902)", "3.3b1 (5902)")
    }

    func test_compareVersion_reverseDateBasedVersions_matchesSparkleOrdering() {
        assertAscending("201210251627", "201211051041")
        assertEqual("201210251627.0", "201210251627")
        assertEqual("201210251627", "201210251627.0")
    }

    func test_compareVersion_numericComponentOverflow_matchesNSStringLongLongValueClamping() {
        assertEqual("9223372036854775808", "9223372036854775807")
        assertEqual("999999999999999999999999", "9223372036854775807")
        assertDescending("999999999999999999999999", "9223372036854775806")
    }

    func test_compareVersion_keycapDigit_usesNSStringUTF16Tokenization() {
        assertAscending("1️⃣", "1")
    }

    private func assertAscending(_ versionA: String, _ versionB: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(comparator.compareVersion(versionA, toVersion: versionB), .orderedAscending, file: file, line: line)
    }

    private func assertDescending(_ versionA: String, _ versionB: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(comparator.compareVersion(versionA, toVersion: versionB), .orderedDescending, file: file, line: line)
    }

    private func assertEqual(_ versionA: String, _ versionB: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(comparator.compareVersion(versionA, toVersion: versionB), .orderedSame, file: file, line: line)
    }
}
