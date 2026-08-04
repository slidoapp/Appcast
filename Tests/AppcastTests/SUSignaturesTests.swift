//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

final class SUSignaturesTests: XCTestCase {
    func test_init_missingSignature_hasAbsentStatus() {
        let signatures = SUSignatures(optionalEd: nil)

        XCTAssertEqual(signatures.ed25519SignatureStatus, .absent)
        XCTAssertNil(signatures.ed25519Signature)
    }

    func test_init_malformedBase64Signature_hasInvalidStatus() {
        let signatures = SUSignatures(ed: "not base64")

        XCTAssertEqual(signatures.ed25519SignatureStatus, .invalid)
        XCTAssertNil(signatures.ed25519Signature)
    }

    func test_init_wrongLengthSignature_hasInvalidStatus() {
        let signatures = SUSignatures(ed: Data(repeating: 1, count: 63).base64EncodedString())

        XCTAssertEqual(signatures.ed25519SignatureStatus, .invalid)
        XCTAssertNil(signatures.ed25519Signature)
    }

    func test_init_validSignatureWithSurroundingWhitespace_decodesSignature() {
        let expectedSignature = Data(0..<64)
        let signatures = SUSignatures(ed: "  \n\(expectedSignature.base64EncodedString())\n")

        XCTAssertEqual(signatures.ed25519, "  \n\(expectedSignature.base64EncodedString())\n")
        XCTAssertEqual(signatures.ed25519SignatureStatus, .present)
        XCTAssertEqual(signatures.ed25519Signature, expectedSignature)
    }

    func test_init_validDSABase64_decodesSignature() {
        let signatures = SUSignatures(ed: nil, dsa: " AQID\n")

        XCTAssertEqual(signatures.dsaSignatureStatus, .present)
        XCTAssertEqual(signatures.dsaSignature, Data([1, 2, 3]))
    }

    func test_init_invalidDSABase64_marksSignatureInvalid() {
        let signatures = SUSignatures(ed: nil, dsa: "not base64")

        XCTAssertEqual(signatures.dsaSignatureStatus, .invalid)
        XCTAssertNil(signatures.dsaSignature)
    }

    func test_appcastItem_extractsSignatureFromEnclosure() throws {
        let expectedSignature = Data(repeating: 42, count: 64)
        var enclosure = SUAppcast.AttributesDictionary()
        enclosure[SURSSAttribute.URL] = "https://example.com/Acme.zip"
        enclosure[SUAppcastAttribute.EDSignature] = expectedSignature.base64EncodedString()

        var dictionary = SUAppcastItemProperties()
        dictionary[SUAppcastElement.Version] = "1.0"
        dictionary[SURSSElement.Enclosure] = enclosure

        let item = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)

        XCTAssertEqual(item.signatures?.ed25519SignatureStatus, .present)
        XCTAssertEqual(item.signatures?.ed25519Signature, expectedSignature)
    }

    func test_appcastItem_extractsDSASignatureFromEnclosure() throws {
        var enclosure = SUAppcast.AttributesDictionary()
        enclosure[SURSSAttribute.URL] = "https://example.com/Acme.zip"
        enclosure[SUAppcastAttribute.DSASignature] = "AQID"

        var dictionary = SUAppcastItemProperties()
        dictionary[SUAppcastElement.Version] = "1.0"
        dictionary[SURSSElement.Enclosure] = enclosure

        let item = try SUAppcastItem(dictionary: dictionary, relativeTo: nil, stateResolver: nil, resolvedState: nil)

        XCTAssertEqual(item.signatures?.dsaSignatureStatus, .present)
        XCTAssertEqual(item.signatures?.dsaSignature, Data([1, 2, 3]))
    }
}
