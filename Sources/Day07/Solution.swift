import Foundation
import Utils

func rec(solution: Int, partSolution: Int, values: Array<Int>.SubSequence) -> Bool {
  let firstValue = values.first
  let restValues = values.dropFirst()

  if let firstValue = firstValue {
    return rec(solution: solution, partSolution: partSolution + firstValue, values: restValues)
      || rec(solution: solution, partSolution: partSolution * firstValue, values: restValues)
  }

  return partSolution == solution
}

func rec2(solution: Int, partSolution: Int, values: Array<Int>.SubSequence) -> Bool {
  let firstValue = values.first
  let restValues = values.dropFirst()

  if let firstValue = firstValue {
    return rec2(solution: solution, partSolution: partSolution + firstValue, values: restValues)
      || rec2(solution: solution, partSolution: partSolution * firstValue, values: restValues)
      || rec2(solution: solution, partSolution: Int(String(partSolution) + String(firstValue))!, values: restValues)
  }

  return partSolution == solution
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) async -> Int {
    let parsedInput = parseInput(input)

    return parsedInput.filter {
      rec(solution: $0.0, partSolution: $0.1.first!, values: $0.1.dropFirst())
    }
    .map { $0.0 }
    .reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let parsedInput = parseInput(input)

    return parsedInput.filter {
      rec2(solution: $0.0, partSolution: $0.1.first!, values: $0.1.dropFirst())
    }
    .map { $0.0 }
    .reduce(0, +)
  }
}

func parseInput(_ input: String) -> [(Int, [Int])] {
  input.split(separator: "\n").filter { !$0.isEmpty }
    .map {
      let lineParts = $0.split(separator: ":")
      return (Int(lineParts[0])!, lineParts[1].split(separator: " ").map { Int($0)! })
    }
}
