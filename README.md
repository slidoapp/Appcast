# Appcast library

> Sparkle uses appcasts to get information about software updates.
> An appcast is an RSS feed with some extra information for Sparkle’s purposes.

## About

Appcast library is a Swift package to work with Sparkle compatible appcast files.


## Installation

Requires Swift 5.8.


### Swift Package Manager

Add Appcast as a dependency to your project:

```swift
// Package.swift

import PackageDescription

let package = Package(
    name: "YourProjectName",
    dependencies: [
        .package(url: "https://github.com/slidoapp/Appcast.git", from: "0.3.0"),
    ]
)
```


## License

Licensed under [MIT License](LICENSE.txt).  
Source code is based on [Sparkle 2 project](https://sparkle-project.org).
