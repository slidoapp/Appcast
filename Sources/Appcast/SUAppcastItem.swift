//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUAppcastItem.m from Sparkle project.
//

import Foundation

/// The appcast item describing an update in the application's appcast feed.
///
/// An appcast item represents a single update item in the `SUAppcast`  contained within the @c <item> element.
/// 
/// Every appcast item must have a `versionString`, and either a `fileURL` or an `infoURL`.
/// All the remaining properties describing an update to the application are optional.
/// 
/// Extended documentation and examples on using appcast item features are available at:
/// https://sparkle-project.org/documentation/publishing/
public class SUAppcastItem {
    /// An empty appcast item.
    /// 
    /// This may be used as a potential return value in `-[SPUUpdaterDelegate bestValidUpdateInAppcast:forUpdater:]`
    public static let empty = SUAppcastItem()
    
    /**
     The version of the update item.
     
     Sparkle uses this property to compare update items and determine the best available update item in the `SUAppcast`.
     
     This corresponds to the application update's @c CFBundleVersion
     
     This is extracted from the @c <sparkle:version> element, or the @c sparkle:version attribute from the @c <enclosure> element.
     */
    public let versionString: String

    /**
     The human-readable display version of the update item if provided.
     
     This is the version string shown to the user when they are notified of a new update.
     
     This corresponds to the application update's @c CFBundleShortVersionString
     
     This is extracted from the @c <sparkle:shortVersionString> element,  or the @c sparkle:shortVersionString attribute from the @c <enclosure> element.
     
     If no short version string is available, this falls back to the update's `versionString`.
     */
    public let displayVersionString: String

    /**
     The file URL to the update item if provided.
     
     This download contains the actual update Sparkle will attempt to install.
     In cases where a download cannot be provided, an `infoURL` must be provided instead.
     
     A file URL should have an accompanying `contentLength` provided.
     
     This is extracted from the @c url attribute in the @c <enclosure> element.
     */
    public let fileURL: URL?

    /**
     The content length of the download in bytes.
     
     This property is used as a fallback when the server doesn't report the content length of the download.
     In that case, it is used to report progress of the downloading update to the user.
     
     A warning is outputted if this property is not equal the server's expected content length (if provided).
     
     This is extracted from the @c length attribute in the @c <enclosure> element.
     It should be specified if a `fileURL` is provided.
     */
    public let contentLength: Int64;

    /**
     The info URL to the update item if provided.
     
     This informational link is used to direct the user to learn more about an update they cannot download/install directly from within the application.
     The link should point to the product's web page.
     
     The informational link will be used if `informationOnlyUpdate` is @c YES
     
     This is extracted from the @c <link> element.
     */
    public let infoURL: URL?

    /**
     Indicates whether or not the update item is only informational and has no download.
     
     If `infoURL` is not present, this is @c NO
     
     If `fileURL` is not present, this is @c YES
     
     Otherwise this is determined based on the contents extracted from the @c <sparkle:informationalUpdate> element.
     */
    public var isInformationOnlyUpdate: Bool {
        if let state = self._state {
            return state.informationalUpdate;
        } else {
            return self._informationalUpdateVersions?.count == 0;
        }
    }

    /**
     The title of the appcast item if provided.
     
     This is extracted from the @c <title> element.
     */
    public let title: String?

    /**
     The date string of the appcast item if provided.
     
     The `date` property is constructed from this property and expects this string to comply with the following date format:
     `E, dd MMM yyyy HH:mm:ss Z`
     
     This is extracted from the @c <pubDate> element.
     */
    public let dateString: String?

    /**
     The date constructed from the `dateString` property if provided.
     
     Sparkle by itself only uses this property for phased group rollouts specified via `phasedRolloutInterval`, but clients may query this property too.
     
     This date is constructed using the  @c en_US locale.
     */
    public let date: Date?

    /**
     The release notes URL of the appcast item if provided.
     
     This external link points to an HTML file that Sparkle downloads and renders to show the user a new or old update item's changelog.
     
     An alternative to using an external release notes link is providing an embedded `itemDescription`.
     
     This is extracted from the @c <sparkle:releaseNotesLink> element.
     */
    public let releaseNotesURL: URL?

    /**
     The description of the appcast item if provided.
     
     A description may be provided for inline/embedded release notes for new updates using @c <![CDATA[...]]>
     This is an alternative to providing a `releaseNotesURL`.
     
     This is extracted from the @c <description> element.
     */
    public let itemDescription: String?

    /**
     The format of the `itemDescription` for inline/embedded release notes if provided.
     
     This may be:
     - @c html
     - @c plain-text
     
     This is extracted from the @c sparkle:descriptionFormat attribute in the @c <description> element.
     
     If the format is not provided in the @c <description> element of the appcast item, then this property may default to `html`.
     
     If the @c <description> element of the appcast item is not available, this property is `nil`.
     */
    public let itemDescriptionFormat: String?

    /**
     The full release notes URL of the appcast item if provided.
     
     The link should point to the product's full changelog.
     
     Sparkle's standard user interface offers to show these full release notes when a user checks for a new update and no new update is available.
     
     This is extracted from the @c <sparkle:fullReleaseNotesLink> element.
     */
    public let fullReleaseNotesURL: URL?

    /**
     The required minimum system operating version string for this update if provided.
     
     This version string should contain three period-separated components.
     
     Example: @c 10.13.0
     
     Use `minimumOperatingSystemVersionIsOK` property to test if the current running system passes this requirement.
     
     This is extracted from the @c <sparkle:minimumSystemVersion> element.
     */
    public let minimumSystemVersion: String?

    /**
     Indicates whether or not the current running system passes the `minimumSystemVersion` requirement.
     */
    public var minimumOperatingSystemVersionIsOK: Bool {
        if let state = self._state {
            return state.minimumOperatingSystemVersionIsOK
        } else {
            return true
        }
    }

    /**
     The required maximum system operating version string for this update if provided.
     
     A maximum system operating version requirement should only be made in unusual scenarios.
     
     This version string should contain three period-separated components.
     
     Example: @c 10.14.0
     
     Use `maximumOperatingSystemVersionIsOK` property  to test if the current running system passes this requirement.
     
     This is extracted from the @c <sparkle:maximumSystemVersion> element.
     */
    public let maximumSystemVersion: String?

    /**
     Indicates whether or not the current running system passes the `maximumSystemVersion` requirement.
     */
    public var maximumOperatingSystemVersionIsOK: Bool {
        if let state = self._state {
            return state.maximumOperatingSystemVersionIsOK
        } else {
            return true
        }
    }

    /**
     The channel the update item is on if provided.
     
     An update item may specify a custom channel name (such as @c beta) that can only be found by updaters that filter for that channel.
     If no channel is provided, the update item is assumed to be on the default channel.
     
     This is extracted from the @c <sparkle:channel> element.
     Old applications must be using Sparkle 2 or later to interpret the channel element and to ignore unmatched channels.
     */
    public let channel: String?

    /**
     The installation type of the update at `fileURL`
     
     This may be:
     - @c application - indicates this is a regular application update.
     - @c package - indicates this is a guided package installer update.
     - @c interactive-package - indicates this is an interactive package installer update (deprecated; use "package" instead)
     
     This is extracted from the @c sparkle:installationType attribute in the @c <enclosure> element.
     
     If no installation type is provided in the enclosure, the installation type is inferred from the `fileURL` file extension instead.
     
     If the file extension is @c pkg or @c mpkg, the installation type is @c package otherwise it is @c application
     
     Hence, the installation type in the enclosure element only needs to be specified for package based updates distributed inside of a @c zip or other archive format.
     
     Old applications must be using Sparkle 1.26 or later to support downloading bare package updates (`pkg` or `mpkg`) that are not additionally archived inside of a @c zip or other archive format.
     */
    public let installationType: String

    /**
     The phased rollout interval of the update item in seconds if provided.
     
     This is the interval between when different groups of users are notified of a new update.
     
     For this property to be used by Sparkle, the published `date` on the update item must be present as well.
     
     After each interval after the update item's `date`, a new group of users become eligible for being notified of the new update.
     
     This is extracted from the @c <sparkle:phasedRolloutInterval> element.
     
     Old applications must be using Sparkle 1.25 or later to support phased rollout intervals, otherwise they may assume updates are immediately available.
     */
    public let phasedRolloutInterval: Int?

    /**
     The minimum bundle version string this update requires for automatically downloading and installing updates if provided.
     
     If an application's bundle version meets this version requirement, it can install the new update item in the background automatically.
     
     Otherwise if the requirement is not met, the user is always  prompted to install the update. In this case, the update is assumed to be a `majorUpgrade`.
     
     If the update is a `majorUpgrade` and the update is skipped by the user, other future update alerts with the same `minimumAutoupdateVersion` will also be skipped automatically unless an update specifies `ignoreSkippedUpgradesBelowVersion`.
     
     This version string corresponds to the application's @c CFBundleVersion
     
     This is extracted from the @c <sparkle:minimumAutoupdateVersion> element.
     */
    public let minimumAutoupdateVersion: String?

    /**
     Indicates whether or not the update item is a major upgrade.
     
     An update is a major upgrade if the application's bundle version doesn't meet the `minimumAutoupdateVersion` requirement.
     */
    public var isMajorUpgrade: Bool {
        if let state = _state {
            return state.majorUpgrade
        } else {
            return false
        }
    }

    /**
     Previously skipped upgrades by the user will be ignored if they skipped an update whose version precedes this version.
     
     This can only be applied if the update is a `majorUpgrade`.
     
     This version string corresponds to the application's @c CFBundleVersion
     
     This is extracted from the @c <sparkle:ignoreSkippedUpgradesBelowVersion> element.
     
     Old applications must be using Sparkle 2.1 or later, otherwise this property will be ignored.
     */
    public let ignoreSkippedUpgradesBelowVersion: String?

    /**
     Indicates whether or not the update item is critical.
     
     Critical updates are shown to the user more promptly. Sparkle's standard user interface also does not allow them to be skipped.
     
     This is determined and extracted from a top-level @c <sparkle:criticalUpdate> element or a @c sparkle:criticalUpdate element inside of a @c sparkle:tags element.
     
     Old applications must be using Sparkle 2 or later to support the top-level @c <sparkle:criticalUpdate> element.
     */
    public var isCriticalUpdate: Bool {
        if let state = _state {
            return state.criticalUpdate
        } else {
            return _hasCriticalInformation
        }
    }

    /**
     Specifies the operating system the download update is available for if provided.
     
     If this property is not provided, then the supported operating system is assumed to be macOS.
     
     Known potential values for this string are @c macos and @c windows
     
     Sparkle on Mac ignores update items that are for other operating systems.
     This is only useful for sharing appcasts between Sparkle on Mac and Sparkle on other operating systems.
     
     Use `macOsUpdate` property to test if this update item is for macOS.
     
     This is extracted from the @c sparkle:os attribute in the @c <enclosure> element.
     */
    public let osString: String?

    /**
     Indicates whether or not this update item is for macOS.
     
     This is determined from the `osString` property.
     */
    public let isMacOsUpdate: Bool

    /**
     The delta updates for this update item.
     
     Sparkle uses these to download and apply a smaller update based on the version the user is updating from.
     
     The key is based on the @c sparkle:version of the update.
     The value is an update item that will have `deltaUpdate` be @c YES
     
     Clients typically should not need to examine the contents of the delta updates.
     
     This is extracted from the @c <sparkle:deltas> element.
     */
    public let deltaUpdates: Dictionary<String, SUAppcastItem>

    /**
     The expected size of the Sparkle executable file before applying this delta update.
     
     This attribute is used to test if the delta item can still be applied. If Sparkle's executable file has changed (e.g. from having an architecture stripped),
     then the delta item cannot be applied.
     
     This is extracted from the @c sparkle:deltaFromSparkleExecutableSize attribute from the @c <enclosure> element of a @c sparkle:deltas item.
     This attribute is optional for delta update items.
     */
    public let deltaFromSparkleExecutableSize: Int?

    /**
     An expected set of Sparkle's locales present on disk before applying this delta update.
     
     This attribute is used to test if the delta item can still be applied. If Sparkle's list of locales present on disk  (.lproj directories) do not contain any items from this set,
     (e.g. from having localization files stripped) then the delta item cannot be applied. This set does not need to be a complete list of locales. Sparkle may even decide
     to not process all them. 1-10 should be a decent amount.
     
     This is extracted from the @c sparkle:deltaFromSparkleLocales attribute from the @c <enclosure> element of a @c sparkle:deltas item.
     The locales extracted from this attribute are delimited by a comma (e.g. "en,ca,fr,hr,hu"). This attribute is optional for delta update items.
     */
    public let deltaFromSparkleLocales: Set<String>?

    /**
     Indicates whether or not the update item is a delta update.
     
     An update item is a delta update if it is in the `deltaUpdates` of another update item.
     */
    public var isDeltaUpdate: Bool {
        guard let rssElementEnclosure = self.propertiesDictionary[SURSSElement.Enclosure] as? [String: String] else {
            return false
        }
        
        guard let _ = rssElementEnclosure[SUAppcastAttribute.DeltaFrom] else {
            return false
        }
        
        return true
    }

    /**
     The dictionary representing the entire appcast item.
     
     This is useful for querying custom extensions or elements from the appcast item.
     */
    public let propertiesDictionary: [String: Any]
    
    
    // MARK: private members

    // Auxillary appcast item state that needs to be evaluated based on the host state
    // This may be nil if the client creates an SUAppcastItem with a deprecated initializer
    // In that case we will need to fallback to safe behavior
    var _state: SPUAppcastItemState?
    
    // Indicates if we have any critical information. Used as a fallback if state is nil
    var _hasCriticalInformation: Bool
    
    // Indicates the versions we update from that are informational-only
    var _informationalUpdateVersions: InformationalUpdateType?
    
    // MARK: xxx
    static let DELTA_EXPECTED_LOCALES_LIMIT = 15
    static let SUAppcastItemDeltaUpdatesKey = "deltaUpdates"
    static let SUAppcastItemDisplayVersionStringKey = "displayVersionString"
    static let SUAppcastItemSignaturesKey = "signatures"
    static let SUAppcastItemFileURLKey = "fileURL"
    static let SUAppcastItemInfoURLKey = "infoURL"
    static let SUAppcastItemContentLengthKey = "contentLength"
    static let SUAppcastItemDescriptionKey = "itemDescription"
    static let SUAppcastItemDescriptionFormatKey = "itemDescriptionFormat"
    static let SUAppcastItemMaximumSystemVersionKey = "maximumSystemVersion"
    static let SUAppcastItemMinimumSystemVersionKey = "minimumSystemVersion"
    static let SUAppcastItemReleaseNotesURLKey = "releaseNotesURL"
    static let SUAppcastItemFullReleaseNotesURLKey = "fullReleaseNotesURL"
    static let SUAppcastItemTitleKey = "title"
    static let SUAppcastItemVersionStringKey = "versionString"
    static let SUAppcastItemPropertiesKey = "propertiesDictionary"
    static let SUAppcastItemInstallationTypeKey = "SUAppcastItemInstallationType"
    static let SUAppcastItemStateKey = "SUAppcastItemState"
    static let SUAppcastItemDeltaFromSparkleExecutableSizeKey = "SUAppcastItemDeltaFromSparkleExecutableSize"
    static let SUAppcastItemDeltaFromSparkleLocalesKey = "SUAppcastItemDeltaFromSparkleLocales"
    
    static let SURSSElementEnclosure = "enclosure"
    static let SUAppcastAttributeDeltaFrom = "sparkle:deltaFrom"
    
    
    private init() {
        self._hasCriticalInformation = false
        self._informationalUpdateVersions = Set<String>()
        
        self.propertiesDictionary = Dictionary<String, Any>()
        
        // set public properties
        self.versionString = ""
        self.displayVersionString = ""
        self.fileURL = nil
        self.contentLength = 0
        self.infoURL = nil
        self.title = nil
        self.dateString = nil
        self.date = nil
        self.releaseNotesURL = nil
        self.itemDescription = nil
        self.itemDescriptionFormat = nil
        self.fullReleaseNotesURL = nil
        self.minimumSystemVersion = nil
        self.maximumSystemVersion = nil
        self.channel = nil
        self.installationType = ""
        self.phasedRolloutInterval = nil
        self.minimumAutoupdateVersion = nil
        self.ignoreSkippedUpgradesBelowVersion = nil
        self.osString = nil
        self.isMacOsUpdate = false
        self.deltaUpdates = Dictionary<String, SUAppcastItem>()
        self.deltaFromSparkleExecutableSize = nil
        self.deltaFromSparkleLocales = nil
    }
    
    public typealias AppcastItemDictionary = [String: Any]
    typealias InformationalUpdateType = Set<String>
    typealias EnclosureType = SUAppcast.AttributesDictionary
    
    // MARK: private functions
    public init(dictionary dict: AppcastItemDictionary, relativeTo appcastURL: URL?, stateResolver: SPUAppcastItemStateResolver?, resolvedState: SPUAppcastItemState?) throws {
        self._informationalUpdateVersions = Set<String>()
        
        self.propertiesDictionary = dict
        
        self._state = resolvedState
        
        
        self.title = dict[SURSSElement.Title] as? String
        
        let enclosure = dict[SURSSElement.Enclosure] as? EnclosureType
        
        // Try to find a version string.
        // Finding the new version number from the RSS feed is a little bit hacky. There are a few ways:
        // 1. A "sparkle:version" attribute on the enclosure tag, an extension from the RSS spec.
        // 2. If there isn't a version attribute, see if there is a version element (this is now the recommended path).
        // 3. If there isn't a version element, Sparkle will parse the path in the enclosure, expecting
        //    that it will look like this: http://something.com/YourApp_0.5.zip. It'll read whatever's between the last
        //    underscore and the last period as the version number. So name your packages like this: APPNAME_VERSION.extension.
        //    The big caveat with this is that you can't have underscores in your version strings, as that'll confuse Sparkle.
        //    Feel free to change the separator string to a hyphen or something more suited to your needs if you like.
        guard let newVersion = enclosure?[SUAppcastAttribute.Version] ?? dict[SUAppcastElement.Version] as? String else {
            throw AppcastItemError.missingVersion("Appcast feed item lacks <version> element and version could not be deduced.")
        }
        
        self.dateString = dict[SURSSElement.PubDate] as? String
        
        let descriptionDict = dict[SURSSElement.Description] as? SUAppcast.AttributesDictionary
        
        self.itemDescription = descriptionDict?["content"] as? String
        self.itemDescriptionFormat = descriptionDict?["format"] as? String
        
        if let infoUrlString = dict[SURSSElement.Link] as? String {
            guard let infoUrl = URL(string: infoUrlString, relativeTo: appcastURL) else {
                throw AppcastItemError.invalidInfoLink("Info link is not a valid URL value.")
            }
            
            if infoUrl.scheme != "https" {
                throw AppcastItemError.invalidInfoLink("Info link is not using secure HTTPS scheme.")
            }
            
            self.infoURL = infoUrl
        } else {
            self.infoURL = nil
        }
        
        // Need an info URL or an enclosure URL. Former to show "More Info"
        //    page, latter to download & install:
        // TODO: add check
        
        if self.infoURL != nil {
            self._informationalUpdateVersions = enclosure != nil ? dict[SUAppcastElement.InformationalUpdate] as? InformationalUpdateType : InformationalUpdateType()
        } else {
            self._informationalUpdateVersions = nil
        }
        
        var enclosureLength: Int64 = 0
        if let enclosureURLString = enclosure?[SURSSAttribute.URL] {
            let enclosureLengthString = enclosure?[SURSSAttribute.Length] ?? ""
            enclosureLength = Int64(enclosureLengthString) ?? 0
        }
        self.contentLength = max(0, enclosureLength)

        self.osString = enclosure?[SUAppcastAttribute.OsType]
        self.versionString = newVersion
        self.minimumSystemVersion = dict[SUAppcastElement.MinimumSystemVersion] as? String
        self.maximumSystemVersion = dict[SUAppcastElement.MaximumSystemVersion] as? String
        self.minimumAutoupdateVersion = dict[SUAppcastElement.MinimumAutoupdateVersion] as? String
        
        self.ignoreSkippedUpgradesBelowVersion = dict[SUAppcastElement.IgnoreSkippedUpgradesBelowVersion] as? String
        
        // self.channel = self.parseChannel(dict)
        self.channel = nil
        
        // Grab critical update information
        let criticalUpdateDict = dict[SUAppcastElement.CriticalUpdate] as? SUAppcast.AttributesDictionary
        self._hasCriticalInformation = criticalUpdateDict != nil
        
        // Find the appropriate release notes URL.
        if let releaseNotesLinkString = dict[SUAppcastElement.ReleaseNotesLink] as? String {
            self.releaseNotesURL = URL(string: releaseNotesLinkString, relativeTo: appcastURL)
        }
        else if itemDescription?.hasPrefix("https://") ?? false {
            self.releaseNotesURL = URL(string: itemDescription ?? "")
        }
        else {
            self.releaseNotesURL = nil
        }
        
        // Get full release notes URL if informed.
        if let fullReleaseNotesString = dict[SUAppcastElement.FullReleaseNotesLink] as? String {
            self.fullReleaseNotesURL = URL(string: fullReleaseNotesString, relativeTo: appcastURL)
        } else {
            self.fullReleaseNotesURL = nil
        }
        
        self.displayVersionString = ""
        self.fileURL = nil
        self.date = nil
        self.installationType = ""
        self.phasedRolloutInterval = 0
        self.isMacOsUpdate = true
        self.deltaUpdates = [String: SUAppcastItem]()
        self.deltaFromSparkleLocales = ["en"]
        self.deltaFromSparkleExecutableSize = 0
    }
    
    func parseChannel(_ dict: [String: Any]) -> String? {
        guard let channel = dict[SUAppcastElement.Channel] as? String,
              !channel.isEmpty else {
            return nil
        }
        
        var channelAllowedCharacterSet = CharacterSet.alphanumerics
        channelAllowedCharacterSet.insert(charactersIn: "_.-")
        
        if channel.rangeOfCharacter(from: channelAllowedCharacterSet.inverted) != .none {
            return nil
        }
        
        return channel
    }
}

enum AppcastItemError: Error {
    case missingVersion(String)
    case invalidInfoLink(String)
}
