import Foundation

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

public struct Day02 {
    public static func solvePart1() -> Int {
        let reports = readInput()
        return reports.count { report in reportIsSafe(report) }
    }

    public static func solvePart2() -> Int {
        let reports = readInput()
        return reports.count { report in reportIsSafeWithSlack(report) }
    }
}

public func readInput() -> [[Int]] {
    do {
        let input = try String(
            contentsOf: URL(fileURLWithPath: "./Input/Day02/input"), encoding: .utf8)
        let lines = input.split(separator: "\n")
        let reports = lines.map { line in
            return line.split(separator: " ").compactMap { Int($0) }
        }

        return reports
    } catch {
        print("Error reading file: \(error)")
        return []
    }
}
