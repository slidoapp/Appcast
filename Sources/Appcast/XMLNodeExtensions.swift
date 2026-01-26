//
// Copyright 2026 Cisco Systems, Inc. All rights reserved.
// Licensed under MIT-style license (see LICENSE.txt file).
//

import Foundation

/// Provides version comparison facilities for Sparkle.
public extension XMLNode {
    var isSparkleNode: Bool {
        return self.uri == SparkleProject.Namespace
    }
}
