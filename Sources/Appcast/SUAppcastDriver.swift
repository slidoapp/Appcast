//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUAppcastDriver.m from Sparkle project.
//

import Foundation

public class SUAppcastDriver {
    public static func filterSupportedAppcast(_ appcast: SUAppcast, phasedUpdateGroup: NSNumber?, skippedUpdate: Any?, currentDate: Date, hostVersion: String, versionComparator: SUVersionComparison, testOSVersion: Bool, testMinimumAutoupdateVersion: Bool) -> SUAppcast {
        return appcast
    }
    
    public static func bestItem(fromAppcastItems: [SUAppcastItem], getDeltaItem: SUAppcastItem?, withHostVersion: String, comparator: SUVersionComparison) -> SUAppcastItem {
        return fromAppcastItems.first!
    }
    
    public static func bestItem(fromAppcastItems: [SUAppcastItem], getDeltaItem: inout SUAppcastItem?, withHostVersion: String, comparator: SUVersionComparison) -> SUAppcastItem {
        return fromAppcastItems.first!
    }
    
    public static func filterAppcast(_ appcast: SUAppcast, forMacOSAndAllowedChannels allowedChannels: [String]) -> SUAppcast {
        return appcast
    }
    
    // + (SUAppcast *)filterAppcast:(SUAppcast *)appcast forMacOSAndAllowedChannels:(NSSet<NSString *> *)allowedChannels
}
