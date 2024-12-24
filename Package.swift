// swift-tools-version:5.7
import Foundation
import PackageDescription

let days = 1...24

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
      name: "Utils",
      targets: ["Utils"]
    ),
  ]
    + days.map { day in
      .library(
        name: String(format: "Day%02d", day),
        targets: [String(format: "Day%02d", day)])
    },
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-collections.git",
      .upToNextMinor(from: "1.1.0")  // or `.upToNextMajor
    )
  ],
  targets: [
    .target(
      name: "Utils",
      dependencies: [
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .executableTarget(
      name: "Main",
      dependencies: days.map { .target(name: String(format: "Day%02d", $0)) }
    ),
  ]
    + days.map { day in
      .target(
        name: String(format: "Day%02d", day),
        dependencies: [
          "Utils",
          .product(name: "Collections", package: "swift-collections"),
        ]
      )
    }
)
