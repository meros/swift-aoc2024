import Foundation
import Utils

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let (regex, patterns) = parseInput(input)
    
    return patterns.filter { $0.wholeMatch(of: regex) != nil }.count
  }

  public static func solvePart2(_ input: String) async -> Int {
    0
  }
}

func parseInput(_ input: String) -> (Regex<(Substring, Substring)>, [String]) {
  let parts = input.components(separatedBy: "\n\n")
  
  let rules = "^(\(parts[0].split(separator: ", ").joined(separator: "|")))+$"
  let messages = parts[1].components(separatedBy: .newlines)
  
  return (try! Regex(rules), messages)
}
