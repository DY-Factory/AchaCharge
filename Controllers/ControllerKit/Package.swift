// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

/*
Abstract:
The ControllerKit package.
*/

import PackageDescription

let package = Package(
    name: "ControllerKit",
    platforms: [
        .macOS("14.1"),
        .iOS("14.0"),
    ],
    products: [
        .library(
            name: "ControllerKit",
            targets: ["ControllerKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ControllerKit"),
        .testTarget(
            name: "ControllerKitTests",
            dependencies: ["ControllerKit"]),
    ]
)
