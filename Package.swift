// swift-tools-version: 6.1

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
            name: "Appcast",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
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
