// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EvolutionModel",
    platforms: [
        .iOS(.v26), .macOS(.v26), .tvOS(.v26), .watchOS(.v26), .visionOS(.v26)
    ],
    products: [
        .library(
            name: "EvolutionModel",
            targets: ["EvolutionModel"]
        ),
    ],
    dependencies: [
        .package(path: "../EvolutionCore")
    ],
    targets: [
        .target(
            name: "EvolutionModel",
            dependencies: ["EvolutionCore"]
        ),
        .testTarget(
            name: "EvolutionModelTests",
            dependencies: ["EvolutionModel"]
        ),
    ]
)
