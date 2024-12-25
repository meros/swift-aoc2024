import Foundation
import Utils

public class Solution: Day {
  public static var onlySolveExamples: Bool = false
  public static var facitPart1: Int = 3287
  public static var facitPart2: Int = 0

  public static func solvePart1(_ input: String) -> Int {
    let patterns = parsePatterns(input)

    let matchingPairs = patterns.dropLast().enumerated().flatMap { (firstIndex, pattern1) in
      patterns[firstIndex...].dropFirst().map { (pattern1, $0) }
    }.filter { (pattern1, pattern2) in
      pattern1.allSatisfy { !$0.1 || !pattern2[$0.0] }
    }

    return matchingPairs.count
  }
}

private func parsePatterns(_ input: String) -> [Grid<Bool>] {
  input.split(separator: "\n\n").filter { !$0.isEmpty }.map {
    Grid(
      String($0).parseGrid().map {
        $0.map {
          switch $0 {
          case "#": return true
          case ".": return false
          default: fatalError("Invalid character: \($0)")
          }
        }
      })
  }
}
