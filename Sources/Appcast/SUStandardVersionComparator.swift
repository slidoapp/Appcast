//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//
// Based on SUStandardVersionComparator.m from Sparkle project.
//

import Foundation

/// Sparkle's default version comparator.
///
/// This comparator is adapted from MacPAD, by Kevin Ballard.
/// It's "dumb" in that it does essentially string comparison
/// in components split by character type.
public struct SUStandardVersionComparator: SUVersionComparison, Sendable {
    /// A singleton instance of the comparator.
    public static let `default` = SUStandardVersionComparator()
    
    /// Initializes a new instance of the standard version comparator.
    public init() {
    }
    
    enum SUCharacterType {
        case numberType
        case stringType
        case periodSeparatorType
        case punctuationSeparatorType
        case whitespaceSeparatorType
        case dashType
    }
    
    func typeOfCharacter(_ string: String) -> SUCharacterType {
        if string.isEmpty {
            return .stringType
        }

        let character = string[string.startIndex]
        return self.typeOfCharacter(character)
    }
    
    func typeOfCharacter(_ character: Character) -> SUCharacterType {
        if character == "." {
            return .periodSeparatorType
        } else if character == "-" {
            return .dashType
        }

        guard let characterScalar = character.unicodeScalars.first else {
            return .stringType
        }
        
        if CharacterSet.decimalDigits.contains(characterScalar) {
            return .numberType
        } else if CharacterSet.whitespacesAndNewlines.contains(characterScalar) {
            return .whitespaceSeparatorType
        } else if CharacterSet.punctuationCharacters.contains(characterScalar) {
            return .punctuationSeparatorType
        } else {
            return .stringType
        }
    }
    
    func isSeparatorType(characterType: SUCharacterType) -> Bool {
        switch characterType {
        case .numberType, .stringType, .dashType:
            return false
        case .periodSeparatorType, .punctuationSeparatorType, .whitespaceSeparatorType:
            return true
        }
    }
    
    /// If type A and type B are some sort of separator, consider them to be equal
    func isEqualCharacterTypeClassForTypeA(typeA: SUCharacterType, typeB: SUCharacterType) -> Bool {
        switch typeA {
        case .numberType, .stringType, .dashType:
            return (typeA == typeB)
        case .periodSeparatorType, .punctuationSeparatorType, .whitespaceSeparatorType:
            switch typeB {
            case .periodSeparatorType, .punctuationSeparatorType, .whitespaceSeparatorType:
                return true
            case .numberType, .stringType, .dashType:
                return false
            }
        }
    }
    
    func splitVersion(string version: String) -> [String] {
        var s: String
        var oldType: SUCharacterType
        var newType: SUCharacterType
        var parts: [String] = []
        
        if version.count == 0 {
            // Nothing to do here
            return []
        }
        
        s = String(version.prefix(1))
        oldType = self.typeOfCharacter(s)
        
        for character in version.dropFirst() {
            newType = self.typeOfCharacter(character)
            if newType == .dashType {
                break
            }
            if oldType != newType || self.isSeparatorType(characterType: oldType) {
                // We've reached a new segment
                parts.append(s)
                s = String(character)
            } else {
                // Add character to string and continue
                s.append(character)
            }
            oldType = newType
        }
        
        // Add the last part onto the array
        parts.append(s)
        return parts
    }
    
    /// This returns the count of number and period parts at the beginning of the version
    /// See ``balanceVersionParts:partA:partsB`` below
    func countOfNumberAndPeriodStartingParts(_ parts: [String]) -> Int {
        var count = 0
        for part in parts {
            let characterType = self.typeOfCharacter(part)
            if characterType == .numberType || characterType == .periodSeparatorType {
                count += 1
            } else {
                break
            }
        }

        return count
    }
    
    func addNumberAndPeriodParts(to toParts: inout [String], toNumberAndPeriodPartsCount: Int, from fromParts: [String], fromNumberAndPeriodPartsCount: Int) {
        let partsCountDifference = fromNumberAndPeriodPartsCount - toNumberAndPeriodPartsCount
        
        for insertionIndex in toNumberAndPeriodPartsCount ..< (toNumberAndPeriodPartsCount + partsCountDifference) {
            let character = fromParts[insertionIndex]
            let typeA = typeOfCharacter(character)
            if typeA == .periodSeparatorType {
                toParts.insert(".", at: insertionIndex)
            } else if typeA == .numberType {
                toParts.insert("0", at: insertionIndex)
            } else {
                // It should not be possible to get here
                assertionFailure("Cannot add non numeric character \(character) to version part.")
            }
        }
    }
    
    /// If one version starts with "1.0.0" and the other starts with "1.1" we make sure they're balanced
    /// such that the latter version now becomes "1.1.0". This helps ensure that versions like "1.0" and "1.0.0" are equal.
    func balanceVersionParts(partsA: inout [String], partsB: inout [String]) {
        let partANumberAndPeriodPartsCount = self.countOfNumberAndPeriodStartingParts(partsA)
        let partBNumberAndPeriodPartsCount = self.countOfNumberAndPeriodStartingParts(partsB)
        
        if partANumberAndPeriodPartsCount > partBNumberAndPeriodPartsCount {
            self.addNumberAndPeriodParts(to: &partsB, toNumberAndPeriodPartsCount: partBNumberAndPeriodPartsCount, from: partsA, fromNumberAndPeriodPartsCount: partANumberAndPeriodPartsCount)
        } else if partBNumberAndPeriodPartsCount > partANumberAndPeriodPartsCount {
            self.addNumberAndPeriodParts(to: &partsA, toNumberAndPeriodPartsCount: partANumberAndPeriodPartsCount, from: partsB, fromNumberAndPeriodPartsCount: partBNumberAndPeriodPartsCount)
        }
    }
    
    // MARK: SUVersionComparison members
    /// Compares two version strings through textual analysis.
    ///
    /// These version strings should be in the format of x, x.y, or x.y.z where each component is a number.
    /// For example, valid version strings include "1.5.3", "500", or "4000.1"
    /// These versions that are compared correspond to the `CFBundleVersion` values of the updates.
    ///
    /// @param versionA The first version string to compare.
    /// @param versionB The second version string to compare.
    /// @return A comparison result between @c versionA and @c versionB
    public func compareVersion(_ versionA: String, toVersion versionB: String) -> ComparisonResult {
        var partsA = self.splitVersion(string: versionA)
        var partsB = self.splitVersion(string: versionB)
        
        self.balanceVersionParts(partsA: &partsA, partsB: &partsB)
        
        let count = min(partsA.count, partsB.count)
        
        for i in 0 ..< count {
            let partA = partsA[i]
            let partB = partsB[i]
            
            let typeA = self.typeOfCharacter(partA)
            let typeB = self.typeOfCharacter(partB)
            
            // Compare types
            if self.isEqualCharacterTypeClassForTypeA(typeA: typeA, typeB: typeB) {
                // Same type; we can compare
                if typeA == .numberType {
                    let valueA = Int64(partA) ?? 0
                    let valueB = Int64(partB) ?? 0
                    
                    if valueA > valueB {
                        return .orderedDescending
                    }
                    else if valueA < valueB {
                        return .orderedAscending
                    }
                }
                else if typeA == .stringType {
                    let result = partA.compare(partB)
                    if result != .orderedSame {
                        return result
                    }
                }
            }
            else {
                // Not the same type? Now we have to do some validity checking
                if typeA != .stringType && typeB == .stringType {
                    // typeA wins
                    return .orderedDescending
                }
                else if typeA == .stringType && typeB != .stringType {
                    // typeB wins
                    return .orderedAscending
                }
                else {
                    // One is a number and the other is a period. The period is invalid
                    if typeA == .numberType {
                        return .orderedDescending
                    }
                    else {
                        return .orderedAscending
                    }
                }
            }
        }
        
        // The versions are equal up to the point where they both still have parts
        // Lets check to see if one is larger than the other
        if partsA.count != partsB.count {
            // Yep. Lets get the next part of the larger
            // n holds the index of the part we want.
            var missingPart: String
            var shorterResult: ComparisonResult
            var largerResult: ComparisonResult
            
            if partsA.count > partsB.count {
                missingPart = partsA[count]
                shorterResult = .orderedAscending
                largerResult = .orderedDescending
            }
            else {
                missingPart = partsB[count]
                shorterResult = .orderedDescending
                largerResult = .orderedAscending
            }
            
            let missingType = self.typeOfCharacter(missingPart)
            // Check the type
            if missingType == .stringType {
                // It's a string. Shorter version wins
                return shorterResult
            }
            else {
                // It's a number/period. Larger version wins
                return largerResult
            }
        }
        
        // The 2 strings are identical
        return .orderedSame
    }
}
