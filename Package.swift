// swift-tools-version:5.5

import 
PackageDescription

let package = Package(
    name: "AdventOfCode",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "AdventOfCode",
            targets: ["AdventOfCode"])
    ],
    dependencies: [
        // Add any dependencies here
    ],
    targets: [
        .executableTarget(
            name: "AdventOfCode",
            dependencies: [],
            path: "Sources",
            sources: ["main.swift", "1.swift", "2.swift"]  // Add all your day files here
        )
    ]
)
