import Foundation
import Utils

func parseInput(_ input: String) -> ([Character: [Position]], (Int, Int)) {
  let grid = input.split(separator: "\n").map { line in
    line.map { $0 }
  }

  var result: [Character: [Position]] = [:]

  for x in 0..<grid.count {
    for y in 0..<grid[0].count {
      if grid[x][y] != "." {
        var positions = result[grid[x][y]] ?? []
        positions.append(Position(x, y))
        result[grid[x][y]] = positions
      }
    }
  }

  return (result, (grid.count, grid[0].count))
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) async -> Int {
    let parsedInput = parseInput(input)
    return findAntiNodes(parsedInput, 1, 1)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let parsedInput = parseInput(input)
    return findAntiNodes(parsedInput, 0, 100)

  }
}

func findAntiNodes(_ parsedInput: ([Character: [Position]], (Int, Int)), _ from: Int, _ to: Int)
  -> Int
{
  let (positionsMap, (width, height)) = parsedInput

  var antiNodes = Set<Position>()

  for (_, positions) in positionsMap {
    for position in positions {
      for anotherPosition in positions {
        if position == anotherPosition {
          continue
        }

        for i in from...to {
          let antiNodePosition = anotherPosition + (anotherPosition - position) * i
          if antiNodePosition.x < 0 || antiNodePosition.x >= width || antiNodePosition.y < 0
            || antiNodePosition.y >= height
          {
            break
          }
          
          antiNodes.insert(antiNodePosition)
        }
      }
    }
  }

  return antiNodes.count
}
