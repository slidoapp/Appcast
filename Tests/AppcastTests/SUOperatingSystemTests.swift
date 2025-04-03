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
        let osVersion = SUOperatingSystem()

        // Act
        let actualVersionString = osVersion.systemVersionString
        let actualMatchCount = expectedFormat.numberOfMatches(in: actualVersionString, range: NSMakeRange(0, actualVersionString.count))
        
        // Assert
        XCTAssertEqual(actualMatchCount, 1)
    }
    
    func test_systemVersionString_matchesProvidedOperatingSystemVersionValue() throws {
        // Arrange
        let mockVersion = OperatingSystemVersion(majorVersion: 15, minorVersion: 3, patchVersion: 2)
        let osVersion = SUOperatingSystem(mockVersion)

        // Act
        let actualVersionString = osVersion.systemVersionString
        
        // Assert
        XCTAssertEqual(actualVersionString, "15.3.2")
    }
}
