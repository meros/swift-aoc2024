import Foundation
import Utils

public func parseInput(_ input: String) -> [[Int]] {
  input.split(separator: "\n").map {
    $0.split(separator: " ").compactMap { Int($0) }
  }.transposed()
}

public struct Solution: Day {
  public static var facitPart1: Int = 3_569_916

  public static var facitPart2: Int = 26_407_426

  public static func solvePart1(_ input: String) async -> Int {
    let parsedInput = parseInput(input).map { $0.sorted() }.transposed()
    let distances = parsedInput.map { abs($0[0] - $0[1]) }
    return distances.reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let parsedInput = parseInput(input)
    let lastMap = parsedInput[1].reduce(into: [:]) { counts, number in
      counts[number, default: 0] += 1
    }
    return parsedInput[0].map { $0 * (lastMap[$0] ?? 0) }.reduce(0, +)
  }

}
