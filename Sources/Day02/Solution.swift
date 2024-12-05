import Foundation
import Utils

func parseInput(_ input: String) -> [[Int]] {
  input.split(separator: "\n").map { line in
    line.split(separator: " ").compactMap { Int($0) }
  }
}

func reportIsSafe(_ report: [Int]) -> Bool {
  let normalizedReport = report[0] > report[1] ? report.reversed() : report
  let reportDistances = zip(normalizedReport.dropLast(), normalizedReport.dropFirst()).map {
    (a, b) in b - a
  }

  return reportDistances.allSatisfy { distance in distance >= 1 && distance <= 3 }
}

func reportIsSafeWithSlack(_ report: [Int]) -> Bool {
  if reportIsSafe(report) {
    return true
  }

  for i in 0..<(report.count) {
    if reportIsSafe(Array(report[0..<i] + report[(i + 1)...])) {
      return true
    }
  }

  return false
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) -> Int {
    let reports = parseInput(input)
    return reports.count { report in reportIsSafe(report) }
  }

  public static func solvePart2(_ input: String) -> Int {
    let reports = parseInput(input)
    return reports.count { report in reportIsSafeWithSlack(report) }
  }
}
