import Foundation
import Utils

func parseInput(_ input: String) -> [[Substring.Element]] {
  input.split(separator: "\n").map { line in
    line.map { $0 }
  }

}

enum Direction {
  case up
  case down
  case left
  case right
}

let directionMap: [Direction: (Int, Int)] = [
  .up: (-1, 0),
  .down: (1, 0),
  .left: (0, -1),
  .right: (0, 1),
]

struct VisitedPosition: Hashable {
  let x: Int
  let y: Int
  let direction: Direction

  init(x: Int, y: Int, direction: Direction) {
    self.x = x
    self.y = y
    self.direction = direction
  }
}

struct VisitedPositionWithoutDirection: Hashable {
  let x: Int
  let y: Int

  init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
}

public struct Solution: Day {
  public static func solvePart1(_ input: String) -> Int {
    let map = parseInput(input)

    return walkMap(inparsedInput: map) ?? 0
  }

  public static func solvePart2(_ input: String) -> Int {
    let map = parseInput(input)

    let sizeY = map.count
    let sizeX = map[0].count
    var loopingPositions = 0

    for x in (0..<sizeY) {
      for y in (0..<sizeX) {
        var mapCopy = map
        if mapCopy[x][y] == "." {
          mapCopy[x][y] = "#"
          if walkMap(inparsedInput: mapCopy) == nil {
            print("Looping at \(x), \(y)")
            loopingPositions += 1
          }
        }
      }
    }

    return loopingPositions
  }
}

func walkMap(inparsedInput: [[Substring.Element]]) -> Int? {
  var map = inparsedInput
  let sizeY = map.count
  let sizeX = map[0].count

  var position = (0, 0)
  var direction = Direction.up

  for x in (0..<sizeY) {
    for y in (0..<sizeX) {
      if map[x][y] == "^" {
        position = (x, y)
        map[x][y] = "."
        break
      }
    }
  }

  // Start walking
  var visitedPositions = Set<VisitedPosition>()
  var visitedPositionsWithoutDirection = Set<VisitedPositionWithoutDirection>()
  while true {
    let visitedPosition = VisitedPosition(x: position.0, y: position.1, direction: direction)
    if visitedPositions.contains(visitedPosition) {
      return nil
    }

    visitedPositionsWithoutDirection.insert(
      VisitedPositionWithoutDirection(x: position.0, y: position.1))
    visitedPositions.insert(visitedPosition)
    position = (position.0 + directionMap[direction]!.0, position.1 + directionMap[direction]!.1)

    // Out of bounds
    if position.0 < 0 || position.0 >= sizeY || position.1 < 0 || position.1 >= sizeX {
      break
    }

    if map[position.0][position.1] == "#" {
      // Brack out, turn 90 degrees to the right
      position = (
        position.0 - directionMap[direction]!.0, position.1 - directionMap[direction]!.1
      )

      direction =
        direction == .up ? .right : direction == .right ? .down : direction == .down ? .left : .up
    }
  }

  return visitedPositionsWithoutDirection.count
}
