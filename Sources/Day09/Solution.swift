import Foundation
import Utils

func parseFragmentLengths(_ input: String) -> [Int] {
  input.compactMap { char in Int(String(char)) }
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let fragmentLengths = parseFragmentLengths(input)

    var diskBlocks: [Int?] = []
    for i in 0..<fragmentLengths.count {
      if i % 2 == 0 {
        // Add file blocks with file ID
        let fileID = i / 2
        diskBlocks += Array(repeating: fileID, count: fragmentLengths[i])
      } else {
        // Add gap blocks
        diskBlocks += Array(repeating: nil, count: fragmentLengths[i])
      }
    }

    // Compact files by moving blocks from end to first available gap
    for i in 0..<diskBlocks.count {
      let sourceIndex = diskBlocks.count - i - 1
      for targetIndex in 0..<sourceIndex {
        if diskBlocks[targetIndex] == nil {
          let fileID = diskBlocks[sourceIndex]
          diskBlocks[sourceIndex] = nil
          diskBlocks[targetIndex] = fileID
        }
      }
    }

    // Calculate checksum
    let checksum = zip((0...diskBlocks.count), diskBlocks).compactMap { (position, fileID) in
      if let fileID = fileID {
        return position * fileID
      }
      return nil
    }.reduce(0, +)

    return checksum
  }

  public static func solvePart2(_ input: String) async -> Int {
    let fragmentLengths = parseFragmentLengths(input)

    var diskBlocks: [Int?] = []
    for i in 0..<fragmentLengths.count {
      if i % 2 == 0 {
        // Add file blocks with file ID
        let fileID = i / 2
        diskBlocks += Array(repeating: fileID, count: fragmentLengths[i])
      } else {
        // Add gap blocks
        diskBlocks += Array(repeating: nil, count: fragmentLengths[i])
      }
    }

    let dataDiskBlocks = zip(Array(0..<fragmentLengths.count), fragmentLengths).filter {
      idx, fileSize in 
      idx % 2 == 0
    }.map {
      idx, fileSize in
      (fileId: idx / 2, fileSize: fileSize)
    }   

    for (fileId, fileSize ) in dataDiskBlocks.reversed() {

      print("At", fileId)

      let potentialSlice = diskBlocks[0..<diskBlocks.firstIndex {
        if let block = $0 {
          return block == fileId
        }

        return false
      }!]
      // Find first free to move this too
      let firstSuitableIndex = zip(Array(0..<potentialSlice.count), potentialSlice).first { idx, block in
        if block != nil {
          return false          
        }      

        return diskBlocks[idx..<idx+fileSize].allSatisfy { $0 == nil }
      }

      if let firstSuitableIndex = firstSuitableIndex {
        diskBlocks = diskBlocks.map { block in
          if block == fileId {
            return nil
          }

          return block
        }
        diskBlocks.replaceSubrange(firstSuitableIndex.0..<firstSuitableIndex.0+fileSize, with: Array(repeating: fileId, count: fileSize))        
      }
    }

    let checksum = zip((0...diskBlocks.count), diskBlocks).compactMap { (i, value) in
      if let value = value {
        return i * value
      }
      return nil
    }.reduce(0, +)

    return checksum
  }
}
