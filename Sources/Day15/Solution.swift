import Foundation
import Utils

enum Space: Character {
  case free = "."
  case block = "#"
  case player = "@"
  case box = "O"
  case unknown = "X"
}

struct Game {
  var map: Grid<Space>
  var instructions: [Direction]
}

func parseInput(_ input: String) -> Game {
  let parts = input.split(separator: "\n\n")

  let part1 = parts[0]
  let part2 = parts[1]

  let grid = Grid(
    String(part1).parseGrid().map {
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
}
