//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUConstants.m from Sparkle project.
//

import Foundation

public struct SUAppcastElement {
    static let Version = SUAppcastAttribute.Version
    static let ShortVersionString = SUAppcastAttribute.ShortVersionString
    static let CriticalUpdate = "sparkle:criticalUpdate"
    static let Deltas = "sparkle:deltas"
    static let MinimumAutoupdateVersion = "sparkle:minimumAutoupdateVersion"
    static let MinimumSystemVersion = "sparkle:minimumSystemVersion"
    static let MaximumSystemVersion = "sparkle:maximumSystemVersion"
    static let ReleaseNotesLink = "sparkle:releaseNotesLink"
    static let FullReleaseNotesLink = "sparkle:fullReleaseNotesLink"
    static let Tags = "sparkle:tags"
    static let PhasedRolloutInterval = "sparkle:phasedRolloutInterval"
    static let InformationalUpdate = "sparkle:informationalUpdate"
    static let Channel = "sparkle:channel"
    static let BelowVersion = "sparkle:belowVersion"
    static let IgnoreSkippedUpgradesBelowVersion = "sparkle:ignoreSkippedUpgradesBelowVersion"
}

public struct SUAppcastAttribute {
    public static let ValueMacOS = "macos"
    public static let DeltaFrom = "sparkle:deltaFrom"
    public static let DeltaFromSparkleExecutableSize = "sparkle:deltaFromSparkleExecutableSize"
    public static let DeltaFromSparkleLocales = "sparkle:deltaFromSparkleLocales"
    public static let DSASignature = "sparkle:dsaSignature"
    public static let EDSignature = "sparkle:edSignature"
    public static let ShortVersionString = "sparkle:shortVersionString"
    public static let Version = "sparkle:version"
    public static let OsType = "sparkle:os"
    public static let InstallationType = "sparkle:installationType"
    public static let Format = "sparkle:format"
}

public struct SURSSElement {
    public static let Description = "description"
    public static let Enclosure = "enclosure"
    public static let Link = "link"
    public static let PubDate = "pubDate"
    public static let Title = "title"
}

public struct SURSSAttribute {
    public static let URL = "url"
    public static let Length = "length"
}
