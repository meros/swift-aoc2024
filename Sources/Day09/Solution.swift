import Foundation
import Utils

func parseInput(_ input: String) -> [Int] {
  input.compactMap {
    char in Int(String(char))
  }
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    var parsedInput = parseInput(input)
    
    var rawDisk: [Int?] = []
    for i in 0..<parsedInput.count {
      print(i % 2, parsedInput[i])
      if i % 2 == 0 {
        // Add file
        rawDisk += Array(repeating: i / 2, count: parsedInput[i])
      } else {
        rawDisk += Array(repeating: nil, count: parsedInput[i])
      }
    }
    
    for i in 0..<rawDisk.count {
      print(i)
      let index = rawDisk.count - i - 1
      for i2 in 0..<index {
        if rawDisk[i2] == nil {
          let value = rawDisk[index]
          rawDisk[index] = nil
          rawDisk[i2] = value
        }
      }
    }

    let checksum = zip((0...rawDisk.count), rawDisk).compactMap { (i, value) in
      if let value = value {
        return i * value
      }
      return nil
    }.reduce(0, +)

    return checksum
  }

  public static func solvePart2(_ input: String) async -> Int {
    let _ = parseInput(input)
    return 0
  }
}
