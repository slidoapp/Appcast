//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SPUDownloadData.m from Sparkle project.
//

import Foundation

/// A class for containing downloaded data along with some information about it.
public struct SPUDownloadData {
    public let data: Data
    public let URL: URL
    public let textEncodingName: String?
    public let MIMEType: String?
    
    public init(withData data: Data, URL: URL, textEncodingName: String?, MIMEType: String?) {
        self.data = data
        self.URL = URL
        self.textEncodingName = textEncodingName
        self.MIMEType = MIMEType
    }
}
