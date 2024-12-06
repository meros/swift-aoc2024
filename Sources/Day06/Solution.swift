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

  mutating func backUp() {
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
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) -> Int {
    let map = parseInput(input)

    return walkMap(map)?.0 ?? 0
  }

  public static func solvePart2(_ input: String) -> Int {
    var map = parseInput(input)

    var loopingPositions = 0

    let allPossiblePositions = walkMap(map)!.1

    for position in allPossiblePositions {
      if map.grid[position.x][position.y] == "." {
        map.grid[position.x][position.y] = "#"

        if checkInfinite(map) {
          loopingPositions += 1
        }

        map.grid[position.x][position.y] = "."
      }
    }

    return loopingPositions
  }
}

func walkMap(_ map: Map) -> (Int, Set<Position>)? {
  var currentPosition = map.startingPosition

  // Start walking
  var visitedPositionsWithDirection = Set<PositionWithDirection>()
  var visitedPositions = Set<Position>()

  while true {
    currentPosition.move()

    // Out of bounds
    if currentPosition.x < 0 || currentPosition.x >= map.gridSizeX || currentPosition.y < 0
      || currentPosition.y >= map.gridSizeY
    {
      return (visitedPositions.count, visitedPositions)
    }

    if map.grid[currentPosition.x][currentPosition.y] == "#" {
      currentPosition.backUp()
    }

    if visitedPositionsWithDirection.contains(currentPosition) {
      return nil
    }

    visitedPositionsWithDirection.insert(currentPosition)
    visitedPositions.insert(Position(x: currentPosition.x, y: currentPosition.y))
  }
}

func checkInfinite(_ map: Map) -> Bool {
  var currentPosition = map.startingPosition

  // Start walking
  var visitedPositionsWithDirection = Set<PositionWithDirection>()

  while true {
    currentPosition.move()

    // Out of bounds
    if currentPosition.x < 0 || currentPosition.x >= map.gridSizeX || currentPosition.y < 0
      || currentPosition.y >= map.gridSizeY
    {
      return false
    }

    if map.grid[currentPosition.x][currentPosition.y] == "#" {
      currentPosition.backUp()
    }

    if visitedPositionsWithDirection.contains(currentPosition) {
      return true
    }

    visitedPositionsWithDirection.insert(currentPosition)
  }
}
