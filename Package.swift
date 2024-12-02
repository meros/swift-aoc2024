// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AdventOfCode2024",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "Main",
            targets: ["Main"]
        ),
        .library(
            name: "Day01",
            targets: ["Day01"]
        ),
        .library(
            name: "Day02",
            targets: ["Day02"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Day01",
            dependencies: []
        ),
        .target(
            name: "Day02",
            dependencies: []
        ),
        .executableTarget(
            name: "Main",
            dependencies: ["Day01", "Day02"]

        ),
    ]
)
