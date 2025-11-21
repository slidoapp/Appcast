## Plan: Port Sparkle Appcast Parser to Swift

Rewrite the Objective-C Appcast parser from Sparkle to Swift in three phases, ensuring all integration test suites pass. Focus on XML parsing, version comparison, state resolution, and filtering logic while maintaining Swift concurrency safety.

### Phase 1: Extended Attributes Support

Parse additional appcast item attributes and metadata currently missing from the Swift implementation.

1. **Add date parsing in [`Sources/Appcast/SUAppcastItem.swift`]** - Implement `date` property from `dateString` using DateFormatter with format "E, dd MMM yyyy HH:mm:ss Z" and `en_US` locale, create shared formatter constant in [`Sources/Appcast/Constants.swift`].

2. **Parse release notes URLs in [`Sources/Appcast/SUAppcastItem.swift`]** - Extract `releaseNotesURL` from `<sparkle:releaseNotesLink>`, extract `fullReleaseNotesURL` from `<sparkle:fullReleaseNotesLink>`, handle special case where `itemDescription` starting with "https://" becomes `releaseNotesURL`.

3. **Add `copyByFilteringItems(_:)` in [`Sources/Appcast/SUAppcast.swift`]** - Implement method that creates filtered appcast copy with subset of items based on predicate block, preserving all metadata (matches Objective-C implementation).

### Phase 2: Phased Rollout Support

Implement time-based phased rollout logic for gradual update distribution.

1. **Verify phased rollout interval parsing in [`Sources/Appcast/SUAppcastItem.swift`]** - Confirm `phasedRolloutInterval` is correctly parsed from `<sparkle:phasedRolloutInterval>` as integer (seconds).

2. **Implement date-based rollout eligibility in [`Sources/Appcast/SUAppcastDriver.swift`]** - Add `itemIsReadyForPhasedRollout(_:)` method that calculates eligibility based on `date + (interval * groupNumber)`, ensure critical updates bypass phased rollout, use parsed `date` property for calculations.

3. **Update filtering pipeline in [`Sources/Appcast/SUAppcastDriver.swift`]** - Integrate phased rollout check into `filterSupportedAppcast(_:)` method, verify logic matches Sparkle's behavior for groups 0-6.

### Phase 3: Delta Updates and Installation Types

Complete delta update support and package installation type detection.

1. **Parse delta metadata attributes in [`Sources/Appcast/SUAppcastItem.swift`]** - Extract `deltaFromSparkleExecutableSize` as `Int` from enclosure attribute, parse `deltaFromSparkleLocales` as `Set<String>` from comma-separated list, handle optional attributes gracefully.

2. **Implement nested delta item creation in [`Sources/Appcast/SUAppcast.swift`]** - Parse `<sparkle:deltas>` container's enclosure elements, recursively create `SUAppcastItem` instances for each delta (with `sparkle:deltaFrom` attribute), populate parent's `deltaUpdates` dictionary keyed by source version, ensure deltas inherit `_state` from parent item.

3. **Add installation type inference in [`Sources/Appcast/SUAppcastItem.swift`]** - Check `sparkle:installationType` attribute in enclosure first, if missing infer from `fileURL` extension: `.pkg` or `.mpkg` → "package", otherwise → "application", implement as computed property or during initialization.

4. **Enhance delta selection in [`Sources/Appcast/SUAppcastDriver.swift`]** - Verify `deltaUpdateFromAppcastItem(_:hostVersion:)` returns best matching delta for host version, ensure delta items can be properly applied based on metadata checks.

### Further Considerations

1. **Date formatter reusability** - Create static DateFormatter in [`Sources/Appcast/Constants.swift`] to avoid recreating formatter instances (performance optimization).

2. **Delta state inheritance** - Deltas should inherit critical/informational state from parent. Should this be explicit during creation or implicit through state resolver?

3. **Error handling for malformed data** - Should we throw errors for invalid dates, malformed delta attributes, or log warnings and continue parsing with safe defaults?
