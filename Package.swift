// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Alloy",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "Alloy",
            targets: ["Alloy"]
        )
    ],
    targets: [
        .target(
            name: "Alloy",
            resources: [
                .process("Shaders/Shared.metal"),
                .process("Shaders/Unlit.metal"),
                .process("Particles/Particles.metal"),
            ]
        )
    ]
)
