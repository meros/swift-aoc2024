import Foundation
import Utils
import Collections

enum Space: Character {
  case free = "."
  case block = "#"
  case player = "@"
  case box = "O"
  case boxLeft = "["
  case boxRight = "]"
  case unknown = "X"
}

struct Game {
  var map: Grid<Space>
  var instructions: [Direction]
}

func parseInput(_ input: String, _ widen: Bool = false) -> Game {
  let parts = input.split(separator: "\n\n")

  let part1 = parts[0]
  let part2 = parts[1]

  var widerPart2 = ""
  for c in part1 {
    switch c {
    case Space.free.rawValue:
      widerPart2 += "\(Space.free.rawValue)\(Space.free.rawValue)"
    case Space.block.rawValue:
      widerPart2 += "\(Space.block.rawValue)\(Space.block.rawValue)"
    case Space.player.rawValue:
      widerPart2 += "\(Space.player.rawValue)\(Space.free.rawValue)"
    case Space.box.rawValue:
      widerPart2 += "\(Space.boxLeft.rawValue)\(Space.boxRight.rawValue)"
    case "\n":
      widerPart2 += "\n"
    default:
      widerPart2 += "XX"
    }
  }
  
  let grid = Grid(
    (widen ? widerPart2 : String(part1)).parseGrid().map {
      $0.map {
        switch $0 {
        case Space.block.rawValue:
          return Space.block
        case Space.free.rawValue:
          return Space.free
        case Space.player.rawValue:
          return Space.player
        case Space.box.rawValue:
          return Space.box
        case Space.boxLeft.rawValue:
          return Space.boxLeft
        case Space.boxRight.rawValue:
          return Space.boxRight
        default:
          return Space.unknown
        }
      }
    })

  let directions = part2.compactMap {
    switch $0 {
    case "^":
      return Direction(0, -1)
    case "v":
      return Direction(0, 1)
    case "<":
      return Direction(-1, 0)
    case ">":
      return Direction(1, 0)
    default:
      return nil
    }
  }

  return Game(map: grid, instructions: directions)
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    var game = parseInput(input)

    while game.instructions.count > 0 {
      let instruction = game.instructions.removeFirst()

      var playerPosition: Position? = nil
      game.map.forEach { p, c in
        if c == Space.player {
          playerPosition = p
        }
      }

      for i in 1..<max(game.map.width, game.map.height) {
        let checkPos = playerPosition! + instruction * i
        if !game.map.inBounds(checkPos) || game.map[checkPos] == Space.block {
          break
        }

        if game.map[checkPos] == Space.box {
          continue
        }

        if game.map[checkPos] == Space.free {
          for j in stride(from: i, through: 1, by: -1) {
            game.map[playerPosition! + instruction * j] =
              game.map[playerPosition! + instruction * (j - 1)]
          }

          game.map[playerPosition!] = Space.free
          break
        }
      }
    }

    var score = 0
    game.map.forEach { p, s in
      if s == Space.box {
        score += (p.x + p.y * 100)
      }
    }

    return score
  }

  public static func solvePart2(_ input: String) async -> Int {
    var game = parseInput(input, true)

    while game.instructions.count > 0 {
      let instruction = game.instructions.removeFirst()
      var playerPosition: Position? = nil
      game.map.forEach { p, c in
        if c == Space.player {
          playerPosition = p
        }
      }

      let operations = push(&game, playerPosition!, instruction)
      for operation in operations {
        game.map[operation.to] = game.map[operation.from]
        game.map[operation.from] = Space.free
      }
    }

    var score = 0
    game.map.forEach { p, s in
      if s == Space.boxLeft {
        score += (p.x + p.y * 100)
      }
    }

    return score
  }
}

struct Operation: Hashable {
  let from: Position
  let to: Position
}

func push(_ game: inout Game, _ from: Position, _ direction: Direction)
  -> OrderedSet<Operation>
{
  let to = from + direction

  // Cannot move
  if !game.map.inBounds(to) || game.map[to] == Space.block {
    return []
  }

  // Ok to move!
  if game.map[to] == Space.free {
    return [Operation(from: from, to: to)]
  }

  // Handle up/down
  if direction.dy != 0 && game.map[to] == Space.boxLeft {
    let pushLeftOperation = push(&game, to, direction)
    let pushRightOperation = push(&game, to + Direction(1, 0), direction)

    if pushLeftOperation.count > 0 && pushRightOperation.count > 0 {
      var result = pushLeftOperation
      result.append(contentsOf: pushRightOperation)
      result.append(contentsOf: [Operation(from:from, to:to)])
      return result
    } else {
      return []
    }
  }

  if direction.dy != 0 && game.map[to] == Space.boxRight {
    let pushLeftOperation = push(&game, to + Direction(-1, 0), direction)
    let pushRightOperation = push(&game, to, direction)

    if pushLeftOperation.count > 0 && pushRightOperation.count > 0 {
      var result = pushLeftOperation
      result.append(contentsOf: pushRightOperation)
      result.append(contentsOf: [Operation(from:from, to:to)])      
      return result
    } else {
      return []
    }
  }

  // Handle right/left
  if direction.dx != 0 && (game.map[to] == Space.boxLeft || game.map[to] == Space.boxRight) {
    let pushOperation = push(&game, to, direction)

    if pushOperation.count > 0 {
      var result = pushOperation
      result.append(contentsOf: [Operation(from:from, to:to)])      
      return result
    } else {
      return []
    }
  }

  return []
}
