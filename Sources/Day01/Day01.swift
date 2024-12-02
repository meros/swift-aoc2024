import DayUtils
import Foundation

public struct Day01: Day {
    public static func solvePart1(_ input: String) -> Int {
        let parsedInput = parseInput(input)
        let sortedInput = parsedInput.map { $0.sorted() }
        let transposed = sortedInput[0].indices.map { index in
            sortedInput.map { $0[index] }
        }
        let distances = transposed.map { abs($0[0] - $0[1]) }
        return distances.reduce(0, +)
    }

    public static func solvePart2(_ input: String) -> Int {
        let parsedInput = parseInput(input)
        let lastMap = parsedInput[1].reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        let distances = parsedInput[0].map { $0 * (lastMap[$0] ?? 0) }
        return distances.reduce(0, +)
    }
}

public func parseInput(_ input: String) -> [[Int]] {
    let lines = input.split(separator: "\n")
    let numbersByRow = lines.map {
        $0.split(separator: " ").compactMap { Int($0) }
    }
    let numbersByColumn = numbersByRow[0].indices.map { index in
        numbersByRow.map { $0[index] }
    }

    return numbersByColumn
}
