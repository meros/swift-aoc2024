import Foundation
import Utils

public class Solution: Day {
  public static var onlySolveExamples: Bool = false

  public static var facitPart1: Int = 3287

  // No part 2
  public static var facitPart2: Int = 0

  public static func solvePart1(_ input: String) -> Int {
    let locksAndKeys = parseLocksAndKeys(input)

    let pairs: [(Grid<Bool>, Grid<Bool>)] = locksAndKeys.dropLast().enumerated().flatMap {
      (aIdx, a) -> [(Grid<Bool>, Grid<Bool>)] in
      locksAndKeys[aIdx...].dropFirst().map { (a, $0) }
    }.filter { (a, b) in a.allSatisfy { !$0.1 || !b[$0.0] } }

    return pairs.count
  }
}

func parseLocksAndKeys(_ input: String) -> [Grid<Bool>] {
  input.split(separator: "\n\n").filter { !$0.isEmpty }.map {
    Grid(
      String($0).parseGrid().map {
        $0.map {
          switch $0 {
          case "#": return true
          case ".": return false
          default: fatalError("Unexpected character \($0)")
          }
        }
      })
  }
}
