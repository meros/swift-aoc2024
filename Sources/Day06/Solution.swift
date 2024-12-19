import Foundation
import Utils

public class Solution: Day {
  public static var facitPart1: Int = 5095

  public static var facitPart2: Int = 1933

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
              localMap.grid[pos] = "#"

              if checkInfinite(localMap, &turns) {
                loopCount += 1
              }

              turns.removeAll(keepingCapacity: true)
              localMap.grid[pos] = "."
            }

            return loopCount
          }
        }
        return await group.reduce(0, +)
      }
    }.result.get()
  }
}

func parseInput(_ input: String) -> Map {
  let grid = Grid(input.parseGrid().map { $0 })

  let startingPosition =
    grid.first { pos, value in
      value == "^"
    }.map { pos, value in
      PositionWithDirection(position: pos, direction: .up)
    }!

  return Map(startingPosition: startingPosition, grid: (grid))
}

struct Map {
  let startingPosition: PositionWithDirection
  var grid: Grid<Substring.Element>
}

struct PositionWithDirection: Hashable {
  var position: Position
  var direction: Direction

  mutating func move() {
    position = position + direction
  }

  mutating func backUpAndTurn() {
    position = position - direction
    direction = direction.rotateRight()
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

func walkMap(_ map: Map) -> Set<Position> {
  var current = map.startingPosition
  var visited = Set<Position>()

  while true {
    current.move()

    if !map.grid.inBounds(current.position) {
      return visited
    }

    if map.grid[current.position] == "#" {
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

    if map.grid[current.position] == "#" {
      current.backUpAndTurn()
      if !turns.insert(current).inserted {
        return true
      }
    }
  }
}
