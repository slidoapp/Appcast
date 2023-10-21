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
    
    
    // MARK: private members

    // Auxillary appcast item state that needs to be evaluated based on the host state
    // This may be nil if the client creates an SUAppcastItem with a deprecated initializer
    // In that case we will need to fallback to safe behavior
    var _state: SPUAppcastItemState?
    
    // Indicates if we have any critical information. Used as a fallback if state is nil
    var _hasCriticalInformation: Bool
    
    // Indicates the versions we update from that are informational-only
    var _informationalUpdateVersions: Set<String>
    
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
        
        self.propertiesDictionary = Dictionary<String, AnyObject>()
    }
    
    public let propertiesDictionary: Dictionary<String, Any>
    
    
    // MARK: private functions
    func isDeltaUpdate() -> Bool {
        guard let rssElementEnclosure = self.propertiesDictionary[SURSSElement.Enclosure] as? [String: String] else {
            return false
        }
        
        guard let _ = rssElementEnclosure[SUAppcastAttribute.DeltaFrom] else {
            return false
        }
        
        return true
    }
    
    func isCriticalUpdate() -> Bool {
        if let state = _state {
            return state.criticalUpdate
        } else {
            return _hasCriticalInformation
        }
    }
    
    func isMajorUpgrade() -> Bool {
        if let state = _state {
            return state.majorUpgrade
        } else {
            return false
        }
    }
    
    func minimumOperatingSystemVersionIsOK() -> Bool {
        if let state = self._state {
            return state.minimumOperatingSystemVersionIsOK
        } else {
            return true
        }
    }
    
    func maximumOperatingSystemVersionIsOK() -> Bool {
        if let state = self._state {
            return state.maximumOperatingSystemVersionIsOK
        } else {
            return true
        }
    }
    
    func isInformationOnlyUpdate() -> Bool {
        if let state = self._state {
            return state.informationalUpdate;
        } else {
            return self._informationalUpdateVersions.count == 0;
        }
    }
    
    public init(dictionary dict: [String: Any], relativeTo appcastURL: URL?, stateResolver: SPUAppcastItemStateResolver?, resolvedState: SPUAppcastItemState?) throws {
        self._hasCriticalInformation = false
        self._informationalUpdateVersions = Set<String>()
        
        self.propertiesDictionary = dict
        
        self._state = resolvedState
    }
}
