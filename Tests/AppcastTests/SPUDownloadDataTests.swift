//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import Foundation
import Testing
@testable import Appcast

struct SPUDownloadDataTests {

    @Test func init_SPUDownloadData() throws {
        // Arrange
        let data = Data()
        let url = URL(string: "https://example.org")!
        let textEncodingName = "utf-8"
        let mimeType = "text/plain"

        // Act
        let downloadData = SPUDownloadData(withData: data, URL: url, textEncodingName: textEncodingName, MIMEType: mimeType)

        // Assert
        #expect(downloadData.data == data)
        #expect(downloadData.URL == url)
        #expect(downloadData.textEncodingName == textEncodingName)
        #expect(downloadData.MIMEType == mimeType)
    }
}
