import Algorithms
import Foundation
import Utils

public class Solution: Day {
  public static var onlySolveExamples: Bool = false
  public static var facitPart1: Int = 3287
  public static var facitPart2: Int = 0

  public static func solvePart1(_ i: String) -> Int {
    i.chunks(ofCount: 43).combinations(ofCount: 2).count {
      !zip($0[0], $0[1]).contains { $0 == ("#", "#") }
    }
  }
}
