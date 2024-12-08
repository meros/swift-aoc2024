import Foundation
import Utils

func parseInput(_ input: String) -> ([Character: [Position]], (Int, Int)) {
  let grid = input.split(separator: "\n").map { line in
    line.map { $0 }
  }.transposedChar()

  var result: [Character: [Position]] = [:]

  for x in 0..<grid.count {
    for y in 0..<grid[0].count {
      if grid[x][y] != "." {
        var positions = result[grid[x][y]] ?? []
        positions.append(Position(x: x, y: y))
        result[grid[x][y]] = positions
      }
    }
  }

  return (result, (grid.count, grid[0].count))
}

protocol PositionProtocol: Hashable {
  var x: Int { get }
  var y: Int { get }
}

struct Position: PositionProtocol {
  let x: Int
  let y: Int

  init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  func minus(_ position: Position) -> Position {
    return Position(x: self.x - position.x, y: self.y - position.y)
  }

  func plus(_ position: Position) -> Position {
    return Position(x: self.x + position.x, y: self.y + position.y)
  }

  func multiplied(by factor: Int) -> Position {
    return Position(x: self.x * factor, y: self.y * factor)
  }
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) async -> Int {
    let (positionsMap, (width, height)) = parseInput(input)
    var antiNodes = Set<Position>()

    for (_, positions) in positionsMap {
      for position in positions {
        let newAntiNodes = positions.filter { $0 != position }
          .map { $0.plus($0.minus(position)) }
          .filter { $0.x >= 0 && $0.x < width && $0.y >= 0 && $0.y < height }
        for antiNodePosition in newAntiNodes {
          antiNodes.insert(antiNodePosition)
        }
      }
    }

    return antiNodes.count
  }

  public static func solvePart2(_ input: String) async -> Int {
    let (positionsMap, (width, height)) = parseInput(input)
    var antiNodes = Set<Position>()

    for (_, positions) in positionsMap {
      for position in positions {
        for anotherPosition in positions {
          if position == anotherPosition {
            continue
          }

          let difference = anotherPosition.minus(position)
          for i in 0..<100 {
            let multipliedDifference = difference.multiplied(by: i)
            let antiNodePosition = anotherPosition.plus(multipliedDifference)

            if antiNodePosition.x >= 0 && antiNodePosition.x < width && antiNodePosition.y >= 0
              && antiNodePosition.y < height
            {
              antiNodes.insert(antiNodePosition)
            } else {
              break
            }
          }
        }
      }
    }

    return antiNodes.count
  }
}
