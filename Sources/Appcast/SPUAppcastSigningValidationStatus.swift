//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SPUAppcastSigningValidationStatus.h from Sparkle project.
//

/// Describes whether an appcast feed was validated before it was parsed.
public enum SPUAppcastSigningValidationStatus: Int, Sendable {
    /// The application does not require signed appcasts, so validation was skipped.
    case skipped

    /// The appcast signature was validated successfully.
    case succeeded

    /// Appcast validation failed and items must operate in Sparkle's safe fallback mode.
    case failed
}

enum SUAppcastLinkPolicy: Sendable {
    // Preserves the existing Appcast initializer's behavior for source compatibility.
    case legacyAppcast

    // Matches Sparkle's HTTP/HTTPS URL handling.
    case sparkle
}
