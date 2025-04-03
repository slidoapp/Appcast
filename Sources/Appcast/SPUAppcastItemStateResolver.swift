//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SPUAppcastItemStateResolver.m from Sparkle project.
//

import Foundation

public struct SPUAppcastItemStateResolver {
    let hostVersion: String
    let applicationVersionComparator: SUVersionComparison
    let standardVersionComparator: SUStandardVersionComparator
    
    public init(hostVersion: String, applicationVersionComparator: SUVersionComparison, standardVersionComparator: SUStandardVersionComparator) {
        self.hostVersion = hostVersion
        self.applicationVersionComparator = applicationVersionComparator
        self.standardVersionComparator = standardVersionComparator
    }
    
    func isMinimumOperatingSystemVersionOK(_ minimumSystemVersion: String?) -> Bool {
        var minimumVersionOK = true
        
        guard let minimumSystemVersion, !minimumSystemVersion.isEmpty else {
            return minimumVersionOK
        }
        
        let osVersion = SUOperatingSystem()
        minimumVersionOK = standardVersionComparator.compareVersion(minimumSystemVersion, toVersion: osVersion.systemVersionString) != .orderedDescending
        return minimumVersionOK
    }
     
    func isMaximumOperatingSystemVersionOK(_ maximumSystemVersion: String?) -> Bool {
        var maximumVersionOK = true
        
        guard let maximumSystemVersion, !maximumSystemVersion.isEmpty else {
            return maximumVersionOK
        }
        
        let osVersion = SUOperatingSystem()
        maximumVersionOK = standardVersionComparator.compareVersion(maximumSystemVersion, toVersion: osVersion.systemVersionString) != .orderedAscending
        return maximumVersionOK
    }

    static func isMinimumAutoupdateVersionOK(_ minimumAutoupdateVersion: String?, hostVersion: String, versionComparator: SUVersionComparison) -> Bool {
        return (minimumAutoupdateVersion?.isEmpty ?? true || versionComparator.compareVersion(hostVersion, toVersion: minimumAutoupdateVersion!) != ComparisonResult.orderedAscending)
    }

    func isMinimumAutoupdateVersionOK(_ minimumAutoupdateVersion: String?) -> Bool {
        return SPUAppcastItemStateResolver.isMinimumAutoupdateVersionOK(minimumAutoupdateVersion, hostVersion: self.hostVersion, versionComparator: self.applicationVersionComparator)
    }
    
    func isCriticalUpdate(criticalUpdateDictionary: [String: Any]?) -> Bool {
        // Check if any critical update info is provided
        guard let criticalUpdateDictionary else {
            return false
        }
        
        // If no critical version is supplied, then it is critical
        guard let criticalVersion = criticalUpdateDictionary[SUAppcastAttribute.Version] as? String else {
            return true
        }
        
        // Update is only critical when coming from previous versions
        return self.applicationVersionComparator.compareVersion(self.hostVersion, toVersion: criticalVersion) == .orderedAscending
    }
    
    func isInformationalUpdate(informationalUpdateVersions: Set<String>?) -> Bool {
        guard let informationalUpdateVersions else {
            return false
        }
        
        // Informational only update regardless of version the app is updating from
        if informationalUpdateVersions.count == 0 {
            return true
        }

        // Informational update only for a set of host versions we're updating from
        if informationalUpdateVersions.contains(self.hostVersion) {
            return true
        }
        
        // If an informational update version has a '<' prefix, this is an informational update if
        // hostVersion < this info update version
        for informationalUpdateVersion in informationalUpdateVersions {
            if informationalUpdateVersion.hasPrefix("<") && self.applicationVersionComparator.compareVersion(hostVersion, toVersion: String(informationalUpdateVersion.dropFirst())) == .orderedAscending {
                return true
            }
        }
        
        return false
    }
    
    public func resolveState(informationalUpdateVersions: Set<String>?, minimumOperatingSystemVersion: String?, maximumOperatingSystemVersion: String?, minimumAutoupdateVersion: String?, criticalUpdateDictionary: [String: Any]?) -> SPUAppcastItemState {
        let informationalUpdate = self.isInformationalUpdate(informationalUpdateVersions: informationalUpdateVersions)
        let minimumOperatingSystemVersionIsOK = self.isMinimumOperatingSystemVersionOK(minimumOperatingSystemVersion)
        let maximumOperatingSystemVersionIsOK = self.isMaximumOperatingSystemVersionOK(maximumOperatingSystemVersion)
        let majorUpgrade = !self.isMinimumAutoupdateVersionOK(minimumAutoupdateVersion)
        let criticalUpdate = self.isCriticalUpdate(criticalUpdateDictionary: criticalUpdateDictionary)

        return SPUAppcastItemState(withMajorUpgrade: majorUpgrade, criticalUpdate: criticalUpdate, informationalUpdate: informationalUpdate, minimumOperatingSystemVersionIsOK: minimumOperatingSystemVersionIsOK, maximumOperatingSystemVersionIsOK: maximumOperatingSystemVersionIsOK)
    }
}
