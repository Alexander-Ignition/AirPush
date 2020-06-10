// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "air-push",
    products: [
        .executable(name: "air-push", targets: ["AirPush"]),
        .library(name: "APNs", targets: ["APNs"]),
        .library(name: "Chain", targets: ["Chain"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            .upToNextMinor(from: "0.1.0")
        ),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.0.0"
        ),
    ],
    targets: [
        // CLI app
        .target(name: "AirPush", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Logging", package: "swift-log"),
            .target(name: "APNs"),
            .target(name: "Chain"),
        ]),

        // Apple Push Notification service
        .target(name: "APNs"),
        .testTarget(name: "APNsTests", dependencies: ["APNs"]),

        // Keychain access
        .target(name: "Chain"),
    ]
)
