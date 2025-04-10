//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import Testing
@testable import Appcast

struct SUStandardVersionComparatorTests  {
    // MARK: func typeOfCharacter(_ character: String) tests
    @Test func typeOfCharacter_periodSeparator() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter(".")
        
        // Assert
        #expect(actualCharacterType == SUStandardVersionComparator.SUCharacterType.periodSeparatorType)
    }
    
    @Test func typeOfCharacter_dash() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter("-")
        
        // Assert
        #expect(actualCharacterType == SUStandardVersionComparator.SUCharacterType.dashType)
    }
    
    @Test func typeOfCharacter_number() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter("1")
        
        // Assert
        #expect(actualCharacterType == SUStandardVersionComparator.SUCharacterType.numberType)
    }
    
    @Test func typeOfCharacter_whitespace() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter(" ")
        
        // Assert
        #expect(actualCharacterType == SUStandardVersionComparator.SUCharacterType.whitespaceSeparatorType)
    }
    
    @Test func typeOfCharacter_punctuationSeparator() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter("(")
        
        // Assert
        #expect(actualCharacterType == SUStandardVersionComparator.SUCharacterType.punctuationSeparatorType)
    }
    
    @Test func typeOfCharacter_string() {
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualCharacterType = comparator.typeOfCharacter("")
        
        // Assert
        #expect(actualCharacterType == SUStandardVersionComparator.SUCharacterType.stringType)
    }
    
    // MARK: func countOfNumberAndPeriodStartingParts tests
    @Test func countOfNumberAndPeriodStartingParts_simpleNumericVersion() {
        let comparator = SUStandardVersionComparator()
        let parts = ["1", ".", "0"]
        
        // Act
        let actualCount = comparator.countOfNumberAndPeriodStartingParts(parts)
        
        // Assert
        #expect(actualCount == 3)
    }
    
    // MARK: func splitVersion
    @Test func splitVersion() {
        let expectedParts = ["1", ".", "23", ".", "19", " ", "(", "1234", ")"]
        let comparator = SUStandardVersionComparator()
        
        // Act
        let actualParts = comparator.splitVersion(string: "1.23.19 (1234)")
        
        // Assert
        #expect(actualParts.count == 9)
        #expect(actualParts == expectedParts)
    }
}
