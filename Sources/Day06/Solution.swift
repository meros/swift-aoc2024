import Foundation
import Utils

func parseInput(_ input: String) -> Map {
  let grid = input.split(separator: "\n").map({ line in
    line.map { $0 }
  }).transposedChar()

  var p = PositionWithDirection(x: 0, y: 0, direction: .down)
  for x in (0..<grid.count) {
    for y in (0..<grid[0].count) {
      if grid[x][y] == "^" {
        p = PositionWithDirection(x: x, y: y, direction: .up)
      }
    }
  }

  return Map(grid: grid, p: p)
}

struct Map {
  let startingPosition: PositionWithDirection
  var grid: [[Substring.Element]]
  let gridSizeX: Int
  let gridSizeY: Int

  init(grid: [[Substring.Element]], p: PositionWithDirection) {
    self.grid = grid
    self.startingPosition = p

    self.gridSizeX = grid.count
    self.gridSizeY = grid[0].count
  }
}

enum Direction {
  case up
  case down
  case left
  case right
}

let directionMap: [Direction: (Int, Int)] = [
  .up: (0, -1),
  .down: (0, 1),
  .left: (-1, 0),
  .right: (1, 0),
]

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
}

struct PositionWithDirection: PositionProtocol {
  let x: Int
  let y: Int
  let direction: Direction

  init(x: Int, y: Int, direction: Direction) {
    self.x = x
    self.y = y
    self.direction = direction
  }

  func moved() -> PositionWithDirection {
    PositionWithDirection(
      x: x + directionMap[direction]!.0, y: y + directionMap[direction]!.1, direction: direction)
  }

  func backedUp() -> PositionWithDirection {
    PositionWithDirection(
      x: x - directionMap[direction]!.0,
      y: y - directionMap[direction]!.1,
      direction: direction == .up
        ? .right
        : direction == .right
          ? .down
          : direction == .down
            ? .left
            : .up
    )
  }
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) -> Int {
    let map = parseInput(input)

    return walkMap(map) ?? 0
  }

  public static func solvePart2(_ input: String) -> Int {
    var map = parseInput(input)

    var loopingPositions = 0

    for x in (0..<map.gridSizeX) {
      for y in (0..<map.gridSizeY) {
        if map.grid[x][y] == "." {
          map.grid[x][y] = "#"

          if walkMap(map) == nil {
            loopingPositions += 1
          }

          map.grid[x][y] = "."
        }
      }

      let percentageCompleted = Double(x + 1) / Double(map.gridSizeX) * 100
      let percentageCompletedInt = Int(percentageCompleted)
      let spinner = ["|", "/", "-", "\\"]
      let spinnerIndex = x % spinner.count
      print("Completed \(percentageCompletedInt)% of rows \(spinner[spinnerIndex])")
    }

    return loopingPositions
  }
}

func walkMap(_ map: Map) -> Int? {
  var currentPosition = map.startingPosition

  // Start walking
  var visitedPositionsWithDirection = Set<PositionWithDirection>()
  var visitedPositions = Set<Position>()

  while true {
    currentPosition = currentPosition.moved()

    // Out of bounds
    if currentPosition.x < 0 || currentPosition.x >= map.gridSizeX || currentPosition.y < 0
      || currentPosition.y >= map.gridSizeY
    {
      return visitedPositions.count
    }

    if map.grid[currentPosition.x][currentPosition.y] == "#" {
      currentPosition = currentPosition.backedUp()
    }

    let visitedPosition = PositionWithDirection(
      x: currentPosition.x, y: currentPosition.y, direction: currentPosition.direction)
    if visitedPositionsWithDirection.contains(visitedPosition) {
      return nil
    }

    visitedPositionsWithDirection.insert(visitedPosition)
    visitedPositions.insert(Position(x: currentPosition.x, y: currentPosition.y))
  }
}
