// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleSubtitles",
    defaultLocalization: "en",
    platforms: [.iOS(.v13),
                .tvOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SimpleSubtitles",
            targets: ["SimpleSubtitles"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SimpleSubtitles",
            dependencies: ["SubtitlesInterface"],
            resources: [.process("Resources")]),
        .target(
            name: "SubtitlesInterface",
            dependencies: []),
        .testTarget(
            name: "SimpleSubtitles-Test",
            dependencies: ["SimpleSubtitles", "SubtitlesInterface"]),
    ]
)
