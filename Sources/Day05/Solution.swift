import Foundation
import Utils

func parsedInput(_ input: String) -> ([[Int]], [[Int]]) {
  let parts = input.split(separator: "\n\n")
  let part1Parsed = parts.first!.split(separator: "\n").map {
    $0.split(separator: "|").compactMap { Int($0) }
  }

  let part2Parsed = parts.last!.split(separator: "\n").map {
    $0.split(separator: ",").compactMap { Int($0) }
  }

  return (part1Parsed, part2Parsed)
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) -> Int {
    let (rules, updates) = parsedInput(input)

    let validUpdates = updates.filter { update in
      // Check each number in the update agains the rules
      return zip(update, (0..<update.count)).allSatisfy { (number, index) in
        // Extract all after-rules
        let pagesMustComeAfter = rules.filter { $0[0] == number }.map { $0[1] }
        if !pagesMustComeAfter.allSatisfy({ afterPage in
          if let afterPageIndex = update.firstIndex(of: afterPage) {
            return afterPageIndex > index
          } else {
            return true
          }
        }) {
          return false
        }

        // Extract all before-rules
        let pagesMustComeBefore = rules.filter { $0[1] == number }.map { $0[0] }
        if !pagesMustComeBefore.allSatisfy({ beforePage in
          if let beforePageIndex = update.firstIndex(of: beforePage) {
            return beforePageIndex < index
          } else {
            return true
          }
        }) {
          return false
        }

        return true
      }
    }

    // Find and sum all middle numbers of the valid updates
    return validUpdates.map { $0[($0.count - 1) / 2] }.reduce(0, +)
  }

  public static func solvePart2(_ input: String) -> Int {
    let (rules, updates) = parsedInput(input)

    let invalidUpdates = updates.filter { update in
      // Check each number in the update agains the rules
      return !zip(update, (0..<update.count)).allSatisfy { (number, index) in
        // Extract all after-rules
        let pagesMustComeAfter = rules.filter { $0[0] == number }.map { $0[1] }
        if !pagesMustComeAfter.allSatisfy({ afterPage in
          if let afterPageIndex = update.firstIndex(of: afterPage) {
            return afterPageIndex > index
          } else {
            return true
          }
        }) {
          return false
        }

        // Extract all before-rules
        let pagesMustComeBefore = rules.filter { $0[1] == number }.map { $0[0] }
        if !pagesMustComeBefore.allSatisfy({ beforePage in
          if let beforePageIndex = update.firstIndex(of: beforePage) {
            return beforePageIndex < index
          } else {
            return true
          }
        }) {
          return false
        }

        return true
      }
    }.map { update in
      update.sorted { page1, page2 in
        // Find matching rule
        let ruleB = rules.first { $0[0] == page2 && $0[1] == page1 }
        return ruleB != nil
      }
    }

    // Find and sum all middle numbers of the valid updates
    return invalidUpdates.map { $0[($0.count - 1) / 2] }.reduce(0, +)
  }
}
