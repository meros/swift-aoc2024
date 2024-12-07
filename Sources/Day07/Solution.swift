import Foundation
import Utils

func findSolution(
  _ valuesLeft: Array<Int>.SubSequence, _ partSolution: Int, _ solution: Int,
  includeConcat: Bool = false
) -> Bool {
  // We are done
  if valuesLeft.isEmpty && partSolution == solution {
    return true
  }

  // Impossible to reach the solution
  if valuesLeft.isEmpty || partSolution > solution {
    return false
  }

  let firstValue = valuesLeft.first!
  let valuesLeftFirstDropped = valuesLeft.dropFirst()

  // Try *
  if findSolution(valuesLeftFirstDropped, partSolution * firstValue, solution, includeConcat: includeConcat) {
    return true
  }

  // Try +
  if findSolution(valuesLeftFirstDropped, partSolution + firstValue, solution, includeConcat: includeConcat) {
    return true
  }

  // Try ||
  if includeConcat && findSolution(valuesLeftFirstDropped, Int(String(partSolution) + String(firstValue))!, solution,includeConcat: includeConcat) {
    return true
  }

  return false
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) async -> Int {
    let input = parseInput(input)

    return input.filter { (key, values) in
      findSolution(values[1..<values.count], values.first!, key)
    }.map { (key, _) in key }.reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let input = parseInput(input)

    return input.filter { (key, values) in
      findSolution(values[1..<values.count], values.first!, key, includeConcat: true)
    }.map { (key, _) in key }.reduce(0, +)
  }
}

func parseInput(_ input: String) -> [(Int, [Int])] {
  return
    input
    .components(separatedBy: .newlines)
    .filter { !$0.isEmpty }
    .map { line in
      let parts = line.split(separator: ":")
      return (Int(parts[0])!, parts[1].split(separator: " ").map { Int($0)! })
    }
}
