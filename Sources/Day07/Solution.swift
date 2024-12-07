import Foundation
import Utils

func findSolution(
  _ solution: Int,
  _ partSolution: Int,
  _ valuesLeft: Array<Int>.SubSequence,
  _ includeConcat: Bool = false
) -> Bool {
  // Early exit if the current part solution is already greater than the solution
  if partSolution > solution {
    return false
  }

  let valuesLeftFirstDropped = valuesLeft.dropFirst()
  if let firstValue = valuesLeft.first {
    return findSolution(
      solution,
      partSolution * firstValue,
      valuesLeftFirstDropped,
      includeConcat)
      || findSolution(
        solution,
        partSolution + firstValue,
        valuesLeftFirstDropped,
        includeConcat)
      || (includeConcat
        && findSolution(
          solution, Int(String(partSolution) + String(firstValue))!, valuesLeftFirstDropped,
          includeConcat))
  }

  return partSolution == solution
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) async -> Int {
    let input = parseInput(input)

    return input.filter { (solution, values) in
      findSolution(solution, values.first!, values.dropFirst())
    }.map { (key, _) in key }.reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let input = parseInput(input)

    return input.filter { (solution, values) in
      findSolution(solution, values.first!, values.dropFirst(), true)
    }.map { (key, _) in key }.reduce(0, +)
  }
}

func parseInput(_ input: String) -> [(Int, [Int])] {
  input
    .split(separator: "\n")
    .compactMap {
      let parts = $0.split(separator: ":")
      if let key = Int(parts[0]) {
        let values = parts[1].split(separator: " ").compactMap { Int($0) }
        return (key, values)
      }

      return nil
    }
}
