// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EvolutionCore",
    platforms: [
        .iOS(.v26), .macOS(.v26), .tvOS(.v26), .watchOS(.v26), .visionOS(.v26)
    ],
    products: [
        .library(
            name: "EvolutionCore",
            targets: ["EvolutionCore"]
        ),
    ],
    targets: [
        .target(
            name: "EvolutionCore"
        ),
        .testTarget(
            name: "EvolutionCoreTests",
            dependencies: ["EvolutionCore"]
        ),
    ]
)
