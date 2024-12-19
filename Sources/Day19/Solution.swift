import Foundation
import Utils

public class Solution: Day {
  public static var facitPart1: Int = 240

  public static var facitPart2: Int = 848_076_019_766_013

  public static var onlySolveExamples: Bool = false

  public static func solvePart1(_ input: String) async -> Int {
    let (regex, designs, _) = parseTowelInput(input)
    return designs.filter { $0.wholeMatch(of: regex) != nil }.count
  }

  public static func solvePart2(_ input: String) async -> Int {
    let (_, designs, patterns) = parseTowelInput(input)
    return designs.map { countArrangements(design: $0, patterns: patterns) }.reduce(0, +)
  }
}

private func parseTowelInput(_ input: String) -> (Regex<AnyRegexOutput>, [String], [String]) {
  let parts = input.components(separatedBy: "\n\n")

  let patterns = parts[0].components(separatedBy: ", ")
  let patternsRegex = try! Regex("^(\(parts[0].split(separator: ", ").joined(separator: "|")))+$")
  let designs = parts[1].components(separatedBy: .newlines).filter { !$0.isEmpty }

  return (patternsRegex, designs, patterns)
}

private var arrangementCache = [String: Int]()

private func countArrangements(design: String, patterns: [String]) -> Int {
  if let cached = arrangementCache[design] {
    return cached
  }

  if design.isEmpty {
    arrangementCache[design] = 1
    return 1
  }

  let arrangements =
    patterns
    .filter { design.hasPrefix($0) }
    .map {
      countArrangements(
        design: String(design.dropFirst($0.count)),
        patterns: patterns
      )
    }
    .reduce(0, +)

  arrangementCache[design] = arrangements
  return arrangements
}
