//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SUOperatingSystemTests: XCTestCase {

    func test_systemVersionString_matchesExpectedFormat() throws {
        // Arrange
        let expectedFormat = try NSRegularExpression.init(pattern: "\\d+.\\d+.\\d+")

        // Act
        let actualVersionString = SUOperatingSystem.systemVersionString
        let actualMatchCount = expectedFormat.numberOfMatches(in: actualVersionString, range: NSMakeRange(0, actualVersionString.count))
        
        // Assert
        XCTAssertEqual(actualMatchCount, 1)
    }
}
