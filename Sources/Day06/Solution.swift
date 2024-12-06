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
  var x: Int
  var y: Int
  var direction: Direction

  init(x: Int, y: Int, direction: Direction) {
    self.x = x
    self.y = y
    self.direction = direction
  }

  mutating func move() {
    x = x + directionMap[direction]!.0
    y = y + directionMap[direction]!.1
  }

  mutating func backUpAndTurn() {
    x = x - directionMap[direction]!.0
    y = y - directionMap[direction]!.1
    direction =
      direction == .up
      ? .right
      : direction == .right
        ? .down
        : direction == .down
          ? .left
          : .up

  }

  func asPosition() -> Position {
    return Position(x: x, y: y)
  }
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) -> Int {
    let map = parseInput(input)

    return walkMap(map).count + 1
  }

  public static func solvePart2(_ input: String) -> Int {
    var map = parseInput(input)

    let allPossiblePositions = walkMap(map)

    var numLoopingPositions = 0
    for position in allPossiblePositions {
      map.grid[position.x][position.y] = "#"

      if checkInfinite(map) {
        numLoopingPositions += 1

      }

      map.grid[position.x][position.y] = "."
    }

    return numLoopingPositions
  }
}

func walkMap(_ map: Map) -> Set<Position> {
  var currentPosition = map.startingPosition

  // Start walking
  var visitedPositions = Set<Position>()

  while true {
    currentPosition.move()

    // Out of bounds
    if currentPosition.x < 0 || currentPosition.x >= map.gridSizeX || currentPosition.y < 0
      || currentPosition.y >= map.gridSizeY
    {
      return visitedPositions
    }

    if map.grid[currentPosition.x][currentPosition.y] == "#" {
      currentPosition.backUpAndTurn()
    }

    visitedPositions.insert(currentPosition.asPosition())
  }
}

func checkInfinite(_ map: Map) -> Bool {
  var currentPosition = map.startingPosition

  // Start walking
  var turns = Set<PositionWithDirection>()

  while true {
    currentPosition.move()

    // Out of bounds
    if currentPosition.x < 0 || currentPosition.x >= map.gridSizeX || currentPosition.y < 0
      || currentPosition.y >= map.gridSizeY
    {
      return false
    }

    if map.grid[currentPosition.x][currentPosition.y] == "#" {
      currentPosition.backUpAndTurn()
      let result = turns.insert(currentPosition)
      if !result.inserted {
        return true
      }
    }

  }
}
