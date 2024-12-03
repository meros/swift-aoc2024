import DayUtils
import Foundation

public struct Day02: Day {
    public static func solvePart1(_ input: String) -> Int {
        let reports = parseInput(input)
        return reports.count { report in reportIsSafe(report) }
    }

    public static func solvePart2(_ input: String) -> Int {
        let reports = parseInput(input)
        return reports.count { report in reportIsSafeWithSlack(report) }
    }
}

public func parseInput(_ input: String) -> [[Int]] {
    let lines = input.split(separator: "\n")
    let reports = lines.map { line in
        return line.split(separator: " ").compactMap { Int($0) }
    }

    return reports
}

func getSign(_ a: Int, _ b: Int) -> Int {
    return (a - b) > 0 ? 1 : -1
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
