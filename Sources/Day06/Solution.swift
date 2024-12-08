import Foundation
import Utils

func parseInput(_ input: String) -> Map {
  let grid = input.parseGrid().map { $0 }.transposed()

  var startingPosition = PositionWithDirection(x: 0, y: 0, direction: .down)
  for x in 0..<grid.count {
    for y in 0..<grid[0].count {
      if grid[x][y] == "^" {
        startingPosition = PositionWithDirection(x: x, y: y, direction: .up)
      }
    }
  }

  return Map(grid: grid, startingPosition: startingPosition)
}

struct Map {
  let startingPosition: PositionWithDirection
  var grid: Grid<Substring.Element>

  init(grid: [[Substring.Element]], startingPosition: PositionWithDirection) {
    self.grid = Grid(grid)
    self.startingPosition = startingPosition
  }
}

struct PositionWithDirection: Hashable {
  var position: Position
  var direction: Direction

  init(x: Int, y: Int, direction: Direction) {
    self.position = Position(x, y)
    self.direction = direction
  }

  mutating func move() {
    position = position + direction
  }

  mutating func backUpAndTurn() {
    position = position - direction
    direction = nextDirection(direction)
  }

  private func nextDirection(_ current: Direction) -> Direction {
    switch current {
    case Direction.up: return Direction.right
    case Direction.right: return Direction.down
    case Direction.down: return Direction.left
    case Direction.left: return Direction.up
    default: return current
    }
  }
}

actor PossiblePositionsActor {
  var positions: Set<Position>

  init(_ positions: Set<Position>) {
    self.positions = positions
  }

  func pop() -> Position? {
    positions.popFirst()
  }
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) async -> Int {
    let map = parseInput(input)
    return walkMap(map).count + 1
  }

  public static func solvePart2(_ input: String) async -> Int {
    let map = parseInput(input)
    let actor = PossiblePositionsActor(walkMap(map))

    return await Task {
      await withTaskGroup(of: Int.self) { group in
        for _ in 0..<10 {
          group.addTask {
            var localMap = map
            var turns = Set<PositionWithDirection>()
            var loopCount = 0

            while let pos = await actor.pop() {
              localMap.grid.values[pos.x][pos.y] = "#"

              if checkInfinite(localMap, &turns) {
                loopCount += 1
              }

              turns.removeAll(keepingCapacity: true)
              localMap.grid.values[pos.x][pos.y] = "."
            }

            return loopCount
          }
        }
        return await group.reduce(0, +)
      }
    }.result.get()
  }
}

func walkMap(_ map: Map) -> Set<Position> {
  var current = map.startingPosition
  var visited = Set<Position>()

  while true {
    current.move()

    if !map.grid.inBounds(current.position) {
      return visited
    }

    if map.grid.values[current.position.x][current.position.y] == "#" {
      current.backUpAndTurn()
    }

    visited.insert(current.position)
  }
}

func checkInfinite(_ map: Map, _ turns: inout Set<PositionWithDirection>) -> Bool {
  var current = map.startingPosition

  while true {
    current.move()

    if !map.grid.inBounds(current.position) {
      return false
    }

    if map.grid.values[current.position.x][current.position.y] == "#" {
      current.backUpAndTurn()
      if !turns.insert(current).inserted {
        return true
      }
    }
  }
}
