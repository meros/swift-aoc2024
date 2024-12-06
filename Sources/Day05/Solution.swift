import Foundation
import Utils

struct PageOrderRule: Hashable {
  let first: Int
  let second: Int
}

typealias PageOrderRules = Set<PageOrderRule>
typealias PageUpdates = [[Int]]

func parseInput(_ input: String) -> (PageUpdates, PageOrderRules) {
  let parts = input.split(separator: "\n\n")

  let rules: PageOrderRules = Set(
    parts.first!.split(separator: "\n").compactMap {
      let rule = $0.split(separator: "|").compactMap { Int($0) }
      return rule.count == 2 ? PageOrderRule(first: rule[0], second: rule[1]) : nil
    })

  let updates: PageUpdates = parts.last!.split(separator: "\n").map {
    $0.split(separator: ",").compactMap { Int($0) }
  }

  return (updates, rules)
}

func isValidUpdate(_ update: [Int], _ rules: PageOrderRules) -> Bool {
  zip(update, update.dropFirst()).allSatisfy(getSortingPredicate(rules))
}

func getSortingPredicate(_ rules: PageOrderRules) -> (Int, Int) -> Bool {
  { page1, page2 in rules.contains(PageOrderRule(first: page1, second: page2)) }
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) async -> Int {
    let (updates, rules) = parseInput(input)

    return updates.filter { isValidUpdate($0, rules) }
      .map { $0[($0.count - 1) / 2] }
      .reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let (updates, rules) = parseInput(input)

    return updates.filter { !isValidUpdate($0, rules) }
      .map { $0.sorted(by: getSortingPredicate(rules)) }
      .map { $0[($0.count - 1) / 2] }
      .reduce(0, +)
  }
}
