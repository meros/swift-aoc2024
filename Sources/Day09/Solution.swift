import Foundation
import Utils

public class Solution: Day {
  public static var facitPart1: Int = 6_320_029_754_031

  public static var facitPart2: Int = 6_347_435_485_773

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

    return zip((0...fragmentationLayout.count), fragmentationLayout).compactMap {
      (position, fileID) in
      fileID.map { position * $0 }
    }.reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let fragmentSizes = parseFragmentationMap(input)

    var fileMetadata: [(fileID: Int, startPosition: Int, size: Int)] = []

    var offset = 0
    for i in 0..<fragmentSizes.count {
      if i % 2 == 0 {
        let fileID = i / 2
        fileMetadata.append((fileID, offset, fragmentSizes[i]))
      }

      offset += fragmentSizes[i]
    }

    // Move whole files to leftmost suitable gap
    for (fileID, fileStart, fileSize) in fileMetadata.reversed() {
      let targetPosition =
        zip(fileMetadata.dropLast(), fileMetadata.dropFirst()).enumerated()
        .first { (idx, element) in
          let ((_, aStart, aSize), (_, bStart, _)) = element

          let freeSpaceBetweenFiles = bStart - (aStart + aSize)
          return fileStart >= aStart + aSize && fileSize <= freeSpaceBetweenFiles
        }

      if let targetPosition = targetPosition {
        let (targetMetadataIdx, ((_, targetStart, targetSize), _)) = targetPosition

        fileMetadata.remove(at: fileMetadata.firstIndex { $0.fileID == fileID }!)
        fileMetadata.insert(
          (
            fileID: fileID,
            startPosition: targetStart + targetSize,
            size: fileSize
          ), at: targetMetadataIdx + 1)
      }
    }

    return fileMetadata.reduce(0) { (acc, file) in
      let (fileID, startPosition, size) = file
      // startPosition * fileID + (startPosition + 1) * fileID + ... + (startPosition + size - 1) * fileID

      let innerSum = (startPosition + startPosition + (size - 1)) * size / 2
      let totalSum = fileID * innerSum

      return acc + totalSum
    }
  }
}

func parseFragmentationMap(_ input: String) -> [Int] {
  input.compactMap { char in Int(String(char)) }
}
