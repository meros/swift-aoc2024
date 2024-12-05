import Foundation
import Utils

func parsedInput(_ input: String) -> ([[Int]], [(Int, Int)]) {
  let parts = input.split(separator: "\n\n")

  let rules = parts.first!.split(separator: "\n").map {
    $0.split(separator: "|").compactMap { Int($0) }
  }.map { rule in
    (rule[0], rule[1])
  }

  let updates = parts.last!.split(separator: "\n").map {
    $0.split(separator: ",").compactMap { Int($0) }
  }

  return (updates, rules)
}

func isValidUpdate(_ update: [Int], _ rules: [(Int, Int)]) -> Bool {
  zip(update, update.dropFirst()).allSatisfy(getSortingPredicate(rules))
}

func getSortingPredicate(_ rules: [(Int, Int)]) -> (Int, Int) -> Bool {
  { page1, page2 -> Bool in rules.contains { rule in rule == (page1, page2) } }
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) -> Int {
    let (updates, rules) = parsedInput(input)

    return updates.filter { update in
      isValidUpdate(update, rules)
    }.map { validUpdate in
      validUpdate[(validUpdate.count - 1) / 2]
    }.reduce(0, +)
  }

  public static func solvePart2(_ input: String) -> Int {
    let (updates, rules) = parsedInput(input)

    return updates.filter { update in
      !isValidUpdate(update, rules)
    }.map { update in
      update.sorted(by: getSortingPredicate(rules))
    }.map { validUpdate in
      validUpdate[(validUpdate.count - 1) / 2]
    }.reduce(0, +)
  }
}
