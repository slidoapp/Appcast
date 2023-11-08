// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Appcast",
    products: [
        .library(
            name: "Appcast",
            targets: ["Appcast"]
        ),
    ],
    targets: [
        .target(
            name: "Appcast"
        ),
        .testTarget(
            name: "AppcastTests",
            dependencies: ["Appcast"],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: ["Appcast"],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
