import Foundation
import Utils

func parseFragmentationMap(_ input: String) -> [Int] {
  input.compactMap { char in Int(String(char)) }
}

func calculateFileSystemChecksum(_ fragmentationLayout: [Int?]) -> Int {
  zip((0...fragmentationLayout.count), fragmentationLayout).compactMap { (position, fileID) in
    fileID.map { position * $0 }
  }.reduce(0, +)
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let fragmentSizes = parseFragmentationMap(input)

    var fragmentationLayout: [Int?] = []
    for i in 0..<fragmentSizes.count {
      if i % 2 == 0 {
        // Initialize file blocks with file ID
        let fileID = i / 2
        fragmentationLayout += Array(repeating: fileID, count: fragmentSizes[i])
      } else {
        // Initialize gap blocks
        fragmentationLayout += Array(repeating: nil, count: fragmentSizes[i])
      }
    }

    // Move blocks one at a time from end to first gap
    var rightCursor = fragmentationLayout.count - 1
    var leftCursor = 0

    while rightCursor > leftCursor {
      if fragmentationLayout[leftCursor] != nil {
        leftCursor += 1
        continue
      }

      if fragmentationLayout[rightCursor] == nil {
        rightCursor -= 1
        continue
      }

      // Move file block to gap
      fragmentationLayout[leftCursor] = fragmentationLayout[rightCursor]
      fragmentationLayout[rightCursor] = nil
      leftCursor += 1
      rightCursor -= 1
    }

    return calculateFileSystemChecksum(fragmentationLayout)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let fragmentSizes = parseFragmentationMap(input)

    var fragmentationLayout: [Int?] = []
    var fileMetadata: [(fileID: Int, startPosition: Int, size: Int)] = []

    for i in 0..<fragmentSizes.count {
      if i % 2 == 0 {
        let fileID = i / 2
        fileMetadata.append((fileID, fragmentationLayout.count, fragmentSizes[i]))
        fragmentationLayout += Array(repeating: fileID, count: fragmentSizes[i])
      } else {
        fragmentationLayout += Array(repeating: nil, count: fragmentSizes[i])
      }
    }

    // Move whole files to leftmost suitable gap
    for (fileID, fileStart, fileSize) in fileMetadata.reversed() {
      if let targetPosition = Array(0..<fileStart).first(where: { position in
        fragmentationLayout[position..<position + fileSize].allSatisfy { $0 == nil }
      }) {
        // Clear old file location and move to new position
        fragmentationLayout.replaceSubrange(
          fileStart..<fileStart + fileSize,
          with: Array(repeating: nil, count: fileSize))
        fragmentationLayout.replaceSubrange(
          targetPosition..<targetPosition + fileSize,
          with: Array(repeating: fileID, count: fileSize))
      }
    }

    return calculateFileSystemChecksum(fragmentationLayout)
  }
}
