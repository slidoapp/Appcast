//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUSignatures.m from Sparkle project.
//

import Foundation

public enum SUSigningInputStatus: UInt8, Sendable {
    case absent
    case invalid
    case present
}

public struct SUSignatures: Sendable, Equatable {
    public let ed25519: String
    public let ed25519Signature: Data?
    public let ed25519SignatureStatus: SUSigningInputStatus
    public let dsa: String
    public let dsaSignature: Data?
    public let dsaSignatureStatus: SUSigningInputStatus

    public init(ed ed25519: String) {
        self.init(optionalEd: ed25519, optionalDsa: nil)
    }

    public init(ed ed25519: String?, dsa: String?) {
        self.init(optionalEd: ed25519, optionalDsa: dsa)
    }

    init(optionalEd ed25519: String?, optionalDsa dsa: String? = nil) {
        self.ed25519 = ed25519 ?? ""
        self.dsa = dsa ?? ""

        if let dsa {
            let strippedSignature = dsa.trimmingCharacters(in: .whitespacesAndNewlines)
            if let signature = Data(base64Encoded: strippedSignature) {
                self.dsaSignature = signature
                self.dsaSignatureStatus = .present
            } else {
                self.dsaSignature = nil
                self.dsaSignatureStatus = .invalid
            }
        } else {
            self.dsaSignature = nil
            self.dsaSignatureStatus = .absent
        }

        guard let ed25519 else {
            self.ed25519Signature = nil
            self.ed25519SignatureStatus = .absent
            return
        }

        let strippedSignature = ed25519.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let signature = Data(base64Encoded: strippedSignature), signature.count == 64 else {
            self.ed25519Signature = nil
            self.ed25519SignatureStatus = .invalid
            return
        }

        self.ed25519Signature = signature
        self.ed25519SignatureStatus = .present
    }
}
