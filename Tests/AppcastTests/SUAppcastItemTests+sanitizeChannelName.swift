//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SUAppcastItemTests_sanitizeChannelName: SUAppcastItemBaseTests {
    func test_allowedChannelCharacterSet_containsExpectedCharacters() {
        let allowedCharacterSet = SUAppcastItem.allowedChannelCharacterSet
        
        XCTAssertTrue(allowedCharacterSet.contains("a".unicodeScalars.first!))
        XCTAssertTrue(allowedCharacterSet.contains("Z".unicodeScalars.first!))
        XCTAssertTrue(allowedCharacterSet.contains("0".unicodeScalars.first!))
        XCTAssertTrue(allowedCharacterSet.contains("_".unicodeScalars.first!))
        XCTAssertTrue(allowedCharacterSet.contains(".".unicodeScalars.first!))
        XCTAssertTrue(allowedCharacterSet.contains("-".unicodeScalars.first!))
        XCTAssertFalse(allowedCharacterSet.contains(" ".unicodeScalars.first!))
        XCTAssertFalse(allowedCharacterSet.contains("/".unicodeScalars.first!))
    }
    
    func test_sanitizeChannelName_validValue_returnsSameValue() {
        let channelName = SUAppcastItem.sanitizeChannelName("beta_1.2-3")
        XCTAssertEqual("beta_1.2-3", channelName)
    }
    
    func test_sanitizeChannelName_invalidWhitespace_replacedWithDoubleUnderscore() {
        let channelName = SUAppcastItem.sanitizeChannelName("beta channel")
        XCTAssertEqual("beta__channel", channelName)
    }
    
    func test_sanitizeChannelName_invalidSlash_replacedWithDoubleUnderscore() {
        let channelName = SUAppcastItem.sanitizeChannelName("beta/channel")
        XCTAssertEqual("beta__channel", channelName)
    }
    
    func test_sanitizeChannelName_multipleInvalidCharacters_eachReplaced() {
        let channelName = SUAppcastItem.sanitizeChannelName("beta / nightly")
        XCTAssertEqual("beta______nightly", channelName)
    }
    
    func test_channel_fromDictionary_validChannel_returnsValue() throws {
        var dict = self.createBasicAppcastItemDictionary()
        dict[SUAppcastElement.Channel] = "nightly-2"
        
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: nil)
        
        XCTAssertEqual("nightly-2", item.channel)
    }
    
    func test_channel_fromDictionary_invalidChannel_returnsNil() throws {
        var dict = self.createBasicAppcastItemDictionary()
        dict[SUAppcastElement.Channel] = "nightly channel"
        
        let item = try SUAppcastItem(dictionary: dict, relativeTo: nil, stateResolver: nil, resolvedState: nil)
        
        XCTAssertNil(item.channel)
    }
}
