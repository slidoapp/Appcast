//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SUStandardVersionComparatorTests: XCTestCase {
    func test_init_standardComparatorCanBeInitialized() throws {
        // Arrange & Act
        let actualtComparator = SUStandardVersionComparator()
        
        // Assert
        XCTAssertNotNil(actualtComparator)
    }

    func test_default_comparatorIsAccessibleFromSwift() throws {
        // Arrange & Act
        let actualDefaultComparator = SUStandardVersionComparator.default
        
        // Assert
        XCTAssertNotNil(actualDefaultComparator)
    }
    
    // MARK: func typeOfCharacter(_ character: String) tests
    func test_typeOfCharacter_periodSeparator() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter(".")
        
        // Assert
        XCTAssertEqual(actualCharacterType, SUStandardVersionComparator.SUCharacterType.periodSeparatorType)
    }
    
    func test_typeOfCharacter_dash() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter("-")
        
        // Assert
        XCTAssertEqual(actualCharacterType, SUStandardVersionComparator.SUCharacterType.dashType)
    }
    
    func test_typeOfCharacter_number() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter("1")
        
        // Assert
        XCTAssertEqual(actualCharacterType, SUStandardVersionComparator.SUCharacterType.numberType)
    }
    
    func test_typeOfCharacter_whitespace() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter(" ")
        
        // Assert
        XCTAssertEqual(actualCharacterType, SUStandardVersionComparator.SUCharacterType.whitespaceSeparatorType)
    }
    
    func test_typeOfCharacter_punctuationSeparator() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter("(")
        
        // Assert
        XCTAssertEqual(actualCharacterType, SUStandardVersionComparator.SUCharacterType.punctuationSeparatorType)
    }
    
    func test_typeOfCharacter_string() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter("")
        
        // Assert
        XCTAssertEqual(actualCharacterType, SUStandardVersionComparator.SUCharacterType.stringType)
    }
    
    // MARK: func countOfNumberAndPeriodStartingParts tests
    func test_countOfNumberAndPeriodStartingParts_simpleNumericVersion() {
        let comparator = SUStandardVersionComparator()
        let parts = ["1", ".", "0"]
        
        // Act
        let actualCount = comparator.countOfNumberAndPeriodStartingParts(parts)
        
        // Assert
        XCTAssertEqual(actualCount, 3)
    }
    
    // MARK: func splitVersion
    func test_splitVersion() {
        let expectedParts = ["1", ".", "23", ".", "19", " ", "(", "1234", ")"]
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualParts = comparator.splitVersion(string: "1.23.19 (1234)")
        
        // Assert
        XCTAssertEqual(actualParts.count, 9)
        XCTAssertEqual(actualParts, expectedParts)
    }
}
