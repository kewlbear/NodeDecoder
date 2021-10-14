// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "NodeDecoder",
    products: [
        .library(
            name: "NodeDecoder",
            targets: ["NodeDecoder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kewlbear/nodejs-ios.git", .branch("main")),
        .package(url: "https://github.com/kewlbear/NodeBridge.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "NodeDecoder",
            dependencies: [
                "nodejs-ios",
                "NodeBridge",
            ]),
        .testTarget(
            name: "NodeDecoderTests",
            dependencies: ["NodeDecoder"]),
    ]
)
