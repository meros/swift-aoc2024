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
        var map = result[grid[x][y]] ?? []
        map.append(Position(x: x, y: y))
        result[grid[x][y]] = map
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

  func minus(position: Position) -> Position {
    return Position(x: self.x - position.x, y: self.y - position.y)
  }

  func plus(position: Position) -> Position {
    return Position(x: self.x + position.x, y: self.y + position.y)
  }

  func mult(factor: Int) -> Position {
    return Position(x: self.x * factor, y: self.y * factor)
  }
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) async -> Int {
    let parsedInput = parseInput(input)
    let sizeX = parsedInput.1.0
    let sizeY = parsedInput.1.1

    var antiNodes = Set<Position>()

    for (_, positions) in parsedInput.0 {
      for position in positions {
        let newAntiNodes = positions.filter { $0 != position }
          .map { $0.plus(position: $0.minus(position: position)) }
          .filter { $0.x >= 0 && $0.x < sizeX && $0.y >= 0 && $0.y < sizeY }
        for antiNodePosition in newAntiNodes {
          antiNodes.insert(antiNodePosition)
        }
      }
    }

    return antiNodes.count
  }

  public static func solvePart2(_ input: String) async -> Int {
    let parsedInput = parseInput(input)
    let sizeX = parsedInput.1.0
    let sizeY = parsedInput.1.1

    var antiNodes = Set<Position>()

    for (_, positions) in parsedInput.0 {
      for position in positions {
        for anotherPosition in positions {
          if position == anotherPosition {
            continue
          }

          let diff = anotherPosition.minus(position: position)
          for i: Int in 0..<100 {
            let multDiff = diff.mult(factor: i)
            let antiNodePosition = anotherPosition.plus(position: multDiff)

            if antiNodePosition.x >= 0 && antiNodePosition.x < sizeX && antiNodePosition.y >= 0 && antiNodePosition.y < sizeY {
              print()
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
