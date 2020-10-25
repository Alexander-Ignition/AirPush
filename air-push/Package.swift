// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "air-push",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .executable(name: "air-push", targets: ["AirPush"]),
        .library(name: "APNs", targets: ["APNs"]),
        .library(name: "Chain", targets: ["Chain"]),
        .library(name: "JWT", targets: ["JWT"]),
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
        .package(
            name: "CryptorECC",
            url: "https://github.com/Kitura/BlueECC.git",
            .upToNextMinor(from: "1.2.4")
        )
    ],
    targets: [
        // CLI app
        .target(name: "AirPush", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Logging", package: "swift-log"),
            .target(name: "APNs"),
            .target(name: "Chain"),
            .target(name: "JWT"),
        ]),

        // Apple Push Notification service
        .target(name: "APNs"),
        .testTarget(name: "APNsTests", dependencies: ["APNs"]),

        // Keychain access
        .target(name: "Chain"),
        
        // JSON Web Tokens
        .target(name: "JWT", dependencies: ["CryptorECC"]),
        .testTarget(name: "JWTTests", dependencies: ["JWT"]),
    ]
)
