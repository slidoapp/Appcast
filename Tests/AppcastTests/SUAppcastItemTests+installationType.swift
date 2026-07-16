//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_installationType: SUAppcastItemBaseTests {
    func test_installationType_explicitPackageTypeOnArchive_usesExplicitType() throws {
        let item = try makeItem(fileURL: "https://example.com/Acme.zip", installationType: "package")

        XCTAssertEqual(item.installationType, "package")
    }

    func test_installationType_explicitApplicationTypeOnPackage_usesExplicitType() throws {
        let item = try makeItem(fileURL: "https://example.com/Acme.pkg", installationType: "application")

        XCTAssertEqual(item.installationType, "application")
    }

    func test_installationType_pkgFileWithoutExplicitType_infersPackage() throws {
        let item = try makeItem(fileURL: "https://example.com/Acme.pkg")

        XCTAssertEqual(item.installationType, "package")
    }

    func test_installationType_mpkgFileWithoutExplicitType_infersPackage() throws {
        let item = try makeItem(fileURL: "https://example.com/Acme.mpkg")

        XCTAssertEqual(item.installationType, "package")
    }

    func test_installationType_archiveWithoutExplicitType_infersApplication() throws {
        let item = try makeItem(fileURL: "https://example.com/Acme.zip")

        XCTAssertEqual(item.installationType, "application")
    }

    func test_installationType_invalidExplicitType_throws() {
        XCTAssertThrowsError(try makeItem(fileURL: "https://example.com/Acme.zip", installationType: "script")) { error in
            guard case AppcastItemError.invalidInstallationType = error else {
                return XCTFail("Expected invalidInstallationType, got \(error)")
            }
        }
    }

    func test_installationType_deprecatedInteractivePackageType_throws() {
        XCTAssertThrowsError(try makeItem(fileURL: "https://example.com/Acme.pkg", installationType: "interactive-package")) { error in
            guard case AppcastItemError.invalidInstallationType = error else {
                return XCTFail("Expected invalidInstallationType, got \(error)")
            }
        }
    }

    private func makeItem(fileURL: String, installationType: String? = nil) throws -> SUAppcastItem {
        var dictionary = createBasicAppcastItemDictionary()
        var enclosure = dictionary[SURSSElement.Enclosure] as! SUAppcast.AttributesDictionary
        enclosure[SURSSAttribute.URL] = fileURL
        enclosure[SUAppcastAttribute.InstallationType] = installationType
        dictionary[SURSSElement.Enclosure] = enclosure

        return try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)
    }
}
