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
            name: "DayUtils",
            targets: ["DayUtils"]
        ),
        .library(
            name: "Day01",
            targets: ["Day01"]
        ),
        .library(
            name: "Day02",
            targets: ["Day02"]
        ),
        .library(
            name: "Day03",
            targets: ["Day03"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Day01",
            dependencies: ["DayUtils"]
        ),
        .target(
            name: "Day02",
            dependencies: ["DayUtils"]
        ),
        .target(
            name: "Day03",
            dependencies: ["DayUtils"]
        ),
        .target(
            name: "DayUtils"
        ),
        .executableTarget(
            name: "Main",
            dependencies: ["Day01", "Day02", "Day03"]

        ),
    ]
)
