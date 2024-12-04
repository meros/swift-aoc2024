// swift-tools-version:5.7
import PackageDescription
import Foundation

let days = (1...4)

let package = Package(
    name: "AdventOfCode2024",
    platforms: [
        .macOS(.v13)
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
    ]
        + days.map { day in
            .library(
                name: String(format: "Day%02d", day),
                targets: [String(format: "Day%02d", day)])
        },
    dependencies: [],
    targets: [
        .target(
            name: "DayUtils"
        ),
        .executableTarget(
            name: "Main",
            dependencies: days.map { .target(name: String(format: "Day%02d", $0)) }
        ),
    ]
        + days.map { day in
            .target(
                name: String(format: "Day%02d", day),
                dependencies: ["DayUtils"]
            )
        }
)
