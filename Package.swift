// swift-tools-version:5.7
import Foundation
import PackageDescription

let dayRange: ClosedRange<Int> = {
  let fileManager = FileManager.default
  let sourcePath = "Sources"

  guard let files = try? fileManager.contentsOfDirectory(atPath: sourcePath) else {
    return 1...1  // Fallback range
  }

  let dayNumbers =
    files.compactMap { filename -> Int? in
      guard let dayNumber = filename.wholeMatch(of: #/Day(?<day>\d+)/#)?.output.day else {
        return nil
      }

      return Int(dayNumber)
    }

  guard let min = dayNumbers.min(), let max = dayNumbers.max() else {
    return 1...1  // Fallback range
  }

  print("Found days \(min) to \(max)")
  return min...max
}()

let days = dayRange

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
