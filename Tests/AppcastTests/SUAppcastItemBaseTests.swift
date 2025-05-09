//
// Copyright 2023 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import XCTest
@testable import Appcast

class SUAppcastItemBaseTests: XCTestCase {
    
    func createBasicAppcastItemDictionary() -> SUAppcastItemProperties {
        var dict = SUAppcastItemProperties()
        dict[SURSSElement.Title] = "Acme v1.0"
        dict[SUAppcastElement.Version] = "1.0.0"
        
        return dict
    }
}
