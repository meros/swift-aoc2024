import Foundation
import Utils

public struct Solution: Day {
  public static var facitPart1: Int = 240

  public static var facitPart2: Int = 848076019766013

  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let (regex, patterns, _) = parseInput(input)

    return patterns.filter { $0.wholeMatch(of: regex) != nil }.count
  }

  public static func solvePart2(_ input: String) async -> Int {
    let (_, patterns, rules) = parseInput(input)

    return patterns.map { solveRecursive(desiredPattern: $0, rules: rules) }.reduce(0, +)
  }
}

func parseInput(_ input: String) -> (Regex<AnyRegexOutput>, [String], [String]) {
  let parts = input.components(separatedBy: "\n\n")

  let rules = parts[0].components(separatedBy: ", ")
  let rulesRegex = try! Regex("^(\(parts[0].split(separator: ", ").joined(separator: "|")))+$")
  let messages = parts[1].components(separatedBy: .newlines).filter {
    !$0.isEmpty
  }

  return (rulesRegex, messages, rules)
}

struct CacheKey : Hashable{
  let desiredPattern: String
  let rules: [String]
}

var cache = [CacheKey: Int]()
func solveRecursive(desiredPattern: String, rules: [String]) -> Int {
  if let cached = cache[CacheKey(desiredPattern: desiredPattern, rules: rules)] {
    return cached
  }

  if desiredPattern.isEmpty {
    cache[CacheKey(desiredPattern: desiredPattern, rules: rules)] = 1
    return 1
  }

  let result = rules.filter {
    desiredPattern.hasPrefix($0)
  }.map {
    solveRecursive(desiredPattern: String(desiredPattern.dropFirst($0.count)), rules: rules)
  }.reduce(0, +)

  cache[CacheKey(desiredPattern: desiredPattern, rules: rules)] = result
  return result
}
