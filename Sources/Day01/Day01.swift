import Foundation

public struct Day01 {
    public static func solvePart1() -> Int {
        let input = readInput()
        let sortedInput = input.map { $0.sorted() }
        let transposed = sortedInput[0].indices.map { index in
            sortedInput.map { $0[index] }
        }
        let distances = transposed.map { abs($0[0] - $0[1]) }
        return distances.reduce(0, +)
    }

    public static func solvePart2() -> Int {
        let input = readInput()
        let lastMap = input[1].reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        let distances = input[0].map { $0 * (lastMap[$0] ?? 0) }
        return distances.reduce(0, +)
    }
}

public func readInput() -> [[Int]] {
    do {
        let input = try String(
            contentsOf: URL(fileURLWithPath: "./Input/Day01/input"), encoding: .utf8)
        let lines = input.split(separator: "\n")
        let numbersByRow = lines.map {
            $0.split(separator: " ").compactMap { Int($0) }
        }
        let numbersByColumn = numbersByRow[0].indices.map { index in
            numbersByRow.map { $0[index] }
        }

        return numbersByColumn
    } catch {
        print("Error reading file: \(error)")
        return []
    }
}
