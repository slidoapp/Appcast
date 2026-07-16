//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUAppcastItemTests_signingValidation: SUAppcastItemBaseTests {
    func test_failedValidation_sanitizesVersionStringsAndRemovesUntrustedPresentationContent() throws {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SUAppcastElement.Version] = "123Acme update now install"
        dictionary[SUAppcastElement.ShortVersionString] = "Version 2.0 - install now"
        dictionary[SURSSElement.Description] = [
            "content": "Install this update immediately",
            "format": "plain-text",
        ]
        dictionary[SURSSElement.Link] = "https://example.com/more-info"
        dictionary[SUAppcastElement.CriticalUpdate] = SUAppcast.AttributesDictionary()
        dictionary[SUAppcastElement.FullReleaseNotesLink] = "https://example.com/all-notes"
        dictionary[SUAppcastElement.ReleaseNotesLink] = [
            "content": "https://example.com/release-notes",
            SUAppcastAttribute.EDSignature: Data(repeating: 7, count: 64).base64EncodedString(),
            SURSSAttribute.Length: "1234",
        ]

        let item = try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil,
            signingValidationStatus: .failed
        )

        XCTAssertEqual(item.signingValidationStatus, .failed)
        XCTAssertEqual(item.versionString, "123Acme updat")
        XCTAssertEqual(item.displayVersionString, "Version 2.")
        XCTAssertNil(item.itemDescription)
        XCTAssertNil(item.itemDescriptionFormat)
        XCTAssertNil(item.infoURL)
        XCTAssertNil(item.releaseNotesURL)
        XCTAssertNil(item.releaseNotesSignatures)
        XCTAssertEqual(item.releaseNotesContentLength, 0)
        XCTAssertNil(item.fullReleaseNotesURL)
        XCTAssertFalse(item.isCriticalUpdate)
    }

    func test_failedValidation_rejectsInformationOnlyUpdate() {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary.removeValue(forKey: SURSSElement.Enclosure)
        dictionary[SURSSElement.Link] = "https://example.com/download"

        XCTAssertThrowsError(try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil,
            signingValidationStatus: .failed
        )) { error in
            guard case AppcastItemError.informationalUpdateRejected = error else {
                return XCTFail("Expected informationalUpdateRejected, got \(error)")
            }
        }
    }

    func test_validatedFeed_requiresExplicitVersionInsteadOfFilenameFallback() {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary.removeValue(forKey: SUAppcastElement.Version)
        var enclosure = dictionary[SURSSElement.Enclosure] as! SUAppcast.AttributesDictionary
        enclosure[SURSSAttribute.URL] = "https://example.com/Acme_1.2.3.zip"
        dictionary[SURSSElement.Enclosure] = enclosure

        XCTAssertThrowsError(try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil,
            signingValidationStatus: .succeeded
        )) { error in
            guard case AppcastItemError.missingVersion = error else {
                return XCTFail("Expected missingVersion, got \(error)")
            }
        }
    }

    func test_validatedFeed_acceptsHTTPLinksWhileLegacyInitializerKeepsHTTPSInfoPolicy() throws {
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SURSSElement.Link] = "http://example.com/more-info"

        let validatedItem = try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil,
            signingValidationStatus: .succeeded
        )

        XCTAssertEqual(validatedItem.infoURL?.absoluteString, "http://example.com/more-info")
        XCTAssertThrowsError(try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil
        )) { error in
            guard case AppcastItemError.invalidInfoLink = error else {
                return XCTFail("Expected invalidInfoLink, got \(error)")
            }
        }
    }

    func test_validatedFeed_rejectsNonHTTPDownloadURL() {
        var dictionary = createBasicAppcastItemDictionary()
        var enclosure = dictionary[SURSSElement.Enclosure] as! SUAppcast.AttributesDictionary
        enclosure[SURSSAttribute.URL] = "file:///tmp/Acme.zip"
        dictionary[SURSSElement.Enclosure] = enclosure

        XCTAssertThrowsError(try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil,
            signingValidationStatus: .succeeded
        )) { error in
            guard case AppcastItemError.invalidFileLink = error else {
                return XCTFail("Expected invalidFileLink, got \(error)")
            }
        }
    }

    func test_releaseNotesLink_preservesSignatureAndNSStringLengthParsing() throws {
        let signature = Data(repeating: 9, count: 64).base64EncodedString()
        var dictionary = createBasicAppcastItemDictionary()
        dictionary[SUAppcastElement.ReleaseNotesLink] = [
            "content": "http://example.com/release-notes",
            SUAppcastAttribute.EDSignature: signature,
            SURSSAttribute.Length: "1234 bytes",
        ]

        let item = try SUAppcastItem(
            dictionary: dictionary,
            relativeTo: nil,
            stateResolver: nil,
            resolvedState: nil,
            signingValidationStatus: .succeeded
        )

        XCTAssertEqual(item.releaseNotesURL?.absoluteString, "http://example.com/release-notes")
        XCTAssertEqual(item.releaseNotesSignatures?.ed25519, signature)
        XCTAssertEqual(item.releaseNotesSignatures?.ed25519SignatureStatus, .present)
        XCTAssertEqual(item.releaseNotesContentLength, 1234)
    }

    func test_failedValidation_appcastSkipsRejectedItemsAndPreservesStatusWhenFiltered() throws {
        let xml = """
        <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
          <channel>
            <item>
              <sparkle:version>1.0</sparkle:version>
              <link>https://example.com/information-only</link>
            </item>
            <item>
              <sparkle:version>2.0</sparkle:version>
              <enclosure url="https://example.com/Acme.zip" length="100" />
            </item>
          </channel>
        </rss>
        """

        let appcast = try SUAppcast(
            xmlData: Data(xml.utf8),
            relativeTo: nil,
            stateResolver: nil,
            signingValidationStatus: .failed
        )
        let filteredAppcast = appcast.copyByFilteringItems { _ in true }

        XCTAssertEqual(appcast.items.map(\.versionString), ["2.0"])
        XCTAssertEqual(appcast.items.first?.signingValidationStatus, .failed)
        XCTAssertEqual(filteredAppcast.signingValidationStatus, .failed)
    }
}
