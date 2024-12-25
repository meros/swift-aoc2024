import Foundation
import Utils

public class Solution: Day {
  public static var onlySolveExamples: Bool = false
  public static var facitPart1: Int = 3287
  public static var facitPart2: Int = 0

  public static func solvePart1(_ input: String) -> Int {
    let patterns = parsePatterns(input)

    return patterns.flatMap {
      a -> [([Bool], [Bool])] in
      patterns.map {
        b in
        (a, b)
      }
    }.filter {
      (a, b) in
      zip(a, b).allSatisfy {
        !($0 && $1)
      }
    }.count / 2
  }
}

private func parsePatterns(_ input: String) -> [[Bool]] {
  input.split(separator: "\n\n").filter { !$0.isEmpty }.map {
    $0.compactMap {
      switch $0 {
      case "#": true
      case ".": false
      default: nil
      }
    }
  }
}
