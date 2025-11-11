## Plan: Port Sparkle Appcast Parser to Swift

Rewrite the Objective-C Appcast parser from Sparkle to Swift, ensuring all 12 integration test suites pass. Focus on XML parsing, version comparison, state resolution, and filtering logic while maintaining Swift concurrency safety.

### Steps

1. **Complete `SUAppcastItem` parsing in [`Sources/Appcast/SUAppcastItem.swift`]** - Add `date` property with DateFormatter ("E, dd MMM yyyy HH:mm:ss Z" format), parse release notes URLs (`releaseNotesLink`, `fullReleaseNotesLink`), implement `installationType` inference from file extensions (.pkg/.mpkg → package), and parse delta metadata (`deltaFromSparkleExecutableSize`, `deltaFromSparkleLocales` as Set).

2. **Implement nested delta update creation in [`Sources/Appcast/SUAppcast.swift`]** - Parse `<sparkle:deltas>` container to create full `SUAppcastItem` instances for each delta enclosure (with `sparkle:deltaFrom` attribute), populate parent item's `deltaUpdates` dictionary keyed by source version, and ensure deltas inherit critical/informational state from parent.

3. **Add missing filtering methods to [`Sources/Appcast/SUAppcastDriver.swift`]** - Implement date-based phased rollout checking using parsed `date` property, verify skipped update logic matches Sparkle behavior with `ignoreSkippedUpgradesBelowVersion`, and ensure delta selection returns best match for host version.

4. **Enhance `SUSignatures` structure in [`Sources/Appcast/SUSignatures.swift`]** - Parse EdDSA signature from `sparkle:edSignature` attribute, optionally parse DSA from `sparkle:dsaSignature`, create `SUSignatures` objects with proper initialization, and define signature status enum (absent/present).

5. **Add `copyByFilteringItems(_:)` method to [`Sources/Appcast/SUAppcast.swift`]** - Create filtered copies of appcast with subset of items while preserving metadata (channel, user agent string), used by driver for multi-stage filtering pipeline.

### Further Considerations

1. **Date parsing locale** - DateFormatter must use `en_US` locale explicitly to match Sparkle's RFC 2822 date format. Should this be a constant in [`Sources/Appcast/Constants.swift`]?

2. **Error handling strategy** - Currently throws `AppcastItemError` for missing required fields. Should we add specific errors for malformed dates, invalid URLs, or XML parsing failures to help debugging?

3. **Signature verification scope** - The research shows signature *validation* logic exists in Sparkle but may be out of scope for a parser-only library. Should we only parse signatures without verifying them, or implement full cryptographic validation?
