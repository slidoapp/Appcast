//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SPUDownloadDataTests: XCTestCase {

    func test_init() throws {
        // Arrange
        let data = Data()
        let url = URL(string: "https://example.org")!
        let textEncodingName = "utf-8"
        let mimeType = "text/plain"

        // Act
        let downloadData = SPUDownloadData(withData: data, URL: url, textEncodingName: textEncodingName, MIMEType: mimeType)

        // Assert
        XCTAssertEqual(downloadData.data, data)
        XCTAssertEqual(downloadData.URL, url)
        XCTAssertEqual(downloadData.textEncodingName, textEncodingName)
        XCTAssertEqual(downloadData.MIMEType, mimeType)
    }
}
