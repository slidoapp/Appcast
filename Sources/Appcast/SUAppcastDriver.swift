//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUAppcastDriver.m from Sparkle project.
//

import Foundation

public class SUAppcastDriver {
    public static func itemIsReadyForPhasedRollout(_ item: SUAppcastItem, phasedUpdateGroup: NSNumber?, currentDate: Date, hostVersion: String, versionComparator: SUVersionComparison) -> Bool {
        guard let phasedUpdateGroup, !item.isCriticalUpdate else {
            return true
        }

        guard let phasedRolloutInterval = item.phasedRolloutInterval else {
            return true
        }

        guard let itemReleaseDate = item.date else {
            return true
        }

        let timeSinceRelease = currentDate.timeIntervalSince(itemReleaseDate)
        let timeToWaitForGroup = phasedRolloutInterval * phasedUpdateGroup.intValue

        return timeSinceRelease >= Double(timeToWaitForGroup)
    }
    
    public static func containsSkippedUpdate(item: SUAppcastItem, skippedUpdate: SPUSkippedUpdate?, hostPassesSkippedMajorVersion: Bool, versionComparator: SUVersionComparison) -> Bool {
        guard let skippedUpdate = skippedUpdate else {
            return false
        }

        let skippedMajorVersion = skippedUpdate.majorVersion
        let skippedMajorSubreleaseVersion = skippedUpdate.majorSubreleaseVersion

        if !hostPassesSkippedMajorVersion, let skippedMajorVersion = skippedMajorVersion, let minimumAutoupdateVersion = item.minimumAutoupdateVersion, versionComparator.compareVersion(skippedMajorVersion, toVersion: minimumAutoupdateVersion) != .orderedAscending, (item.ignoreSkippedUpgradesBelowVersion == nil || (skippedMajorSubreleaseVersion != nil && versionComparator.compareVersion(skippedMajorSubreleaseVersion!, toVersion: item.ignoreSkippedUpgradesBelowVersion!) != .orderedAscending)) {
            // If skipped major version is >= than the item's minimumAutoupdateVersion, we can skip the item.
            // But if there is an ignoreSkippedUpgradesBelowVersion, we can only skip the item if the last skipped subrelease
            // version is >= than that version provided by the item
            return true
        }

        if let skippedMinorVersion = skippedUpdate.minorVersion, versionComparator.compareVersion(skippedMinorVersion, toVersion: item.versionString) != .orderedAscending {
            // Item is on a less or equal version than a minor version we've skipped
            // So we skip this item
            return true
        }

        return false
    }
    
    public static func filterSupportedAppcast(_ appcast: SUAppcast, phasedUpdateGroup: NSNumber?, skippedUpdate: SPUSkippedUpdate?, currentDate: Date, hostVersion: String, versionComparator: SUVersionComparison, testOSVersion: Bool, testMinimumAutoupdateVersion: Bool) -> SUAppcast {

        let hostPassesSkippedMajorVersion = SPUAppcastItemStateResolver.isMinimumAutoupdateVersionOK(skippedUpdate?.majorVersion, hostVersion: hostVersion, versionComparator: versionComparator)

        let filteredItems = appcast.items.filter { item in
            let passesOSVersion = !testOSVersion || (item.minimumOperatingSystemVersionIsOK && item.maximumOperatingSystemVersionIsOK)
            let passesPhasedRollout = itemIsReadyForPhasedRollout(item, phasedUpdateGroup: phasedUpdateGroup, currentDate: currentDate, hostVersion: hostVersion, versionComparator: versionComparator)
            let passesMinimumAutoupdateVersion = !testMinimumAutoupdateVersion || !item.isMajorUpgrade
            let passesSkippedUpdates = hostVersion.isEmpty || !containsSkippedUpdate(item: item, skippedUpdate: skippedUpdate, hostPassesSkippedMajorVersion: hostPassesSkippedMajorVersion, versionComparator: versionComparator)

            return passesOSVersion && passesPhasedRollout && passesMinimumAutoupdateVersion && passesSkippedUpdates
        }

        return SUAppcast(items: filteredItems)
    }
    
    public static func deltaUpdate(from appcastItem: SUAppcastItem, hostVersion: String) -> SUAppcastItem? {
        return appcastItem.deltaUpdates[hostVersion]
    }
    
    public static func bestItem(fromAppcastItems: [SUAppcastItem], getDeltaItem: SUAppcastItem?, withHostVersion: String, comparator: SUVersionComparison) -> SUAppcastItem {
        var item: SUAppcastItem?
        for appcastItem in fromAppcastItems {
            if item == nil || comparator.compareVersion(item!.versionString, toVersion: appcastItem.versionString) == .orderedAscending {
                item = appcastItem
            }
        }
        return item!
    }
    
    public static func bestItem(fromAppcastItems: [SUAppcastItem], getDeltaItem: inout SUAppcastItem?, withHostVersion: String, comparator: SUVersionComparison) -> SUAppcastItem {
        let item = bestItem(fromAppcastItems: fromAppcastItems, getDeltaItem: getDeltaItem, withHostVersion: withHostVersion, comparator: comparator)
        if (getDeltaItem != nil) {
            getDeltaItem = deltaUpdate(from: item, hostVersion: withHostVersion)
        }
        return item
    }
    
    public static func filterAppcast(_ appcast: SUAppcast, forMacOSAndAllowedChannels allowedChannels: [String]) -> SUAppcast {
        let filteredItems = appcast.items.filter { item in
            // We will never care about other OS's
            if !item.isMacOsUpdate {
                return false
            }
            
            // Delta updates cannot be top-level entries
            if item.isDeltaUpdate {
                return false
            }
            
            // Item is on default channel
            guard let channel = item.channel else {
                return true
            }
            
            return allowedChannels.contains(channel)
        }
        
        return SUAppcast(items: filteredItems)
    }
    
    // + (SUAppcast *)filterAppcast:(SUAppcast *)appcast forMacOSAndAllowedChannels:(NSSet<NSString *> *)allowedChannels
}
