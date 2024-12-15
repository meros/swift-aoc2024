import Collections
import Foundation
import Utils

let debugPrint = false

struct Game : Hashable {
  var map: Grid<Character>
  var instructions: [Direction]
}

func parseInput(_ input: String, _ widen: Bool = false) -> Game {
  let parts = input.split(separator: "\n\n")

  let part1 = parts[0]
  let part2 = parts[1]

  var widerPart2 = ""
  for c in part1 {
    switch c {
    case ".":
      widerPart2 += ".."
    case "#":
      widerPart2 += "##"
    case "@":
      widerPart2 += "@."
    case "O":
      widerPart2 += "[]"
    case "\n":
      widerPart2 += "\n"
    default:
      widerPart2 += "XX"
    }
  }

  let grid = Grid(
    (widen ? widerPart2 : String(part1)).parseGrid())

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

    solve(&game)

    var score = 0
    game.map.forEach { p, s in
      if s == "O" {
        score += (p.x + p.y * 100)
      }
    }

    return score
  }

  public static func solvePart2(_ input: String) async -> Int {
    var game = parseInput(input, true)
    solve(&game)

    var score = 0
    game.map.forEach { p, s in
      if s == "[" {
        score += (p.x + p.y * 100)
      }
    }

    return score
  }
}

func solve(_ game: inout Game) {
  while game.instructions.count > 0 {
    let instruction = game.instructions.removeFirst()

    if debugPrint {
      for y in 0..<game.map.height {
        for x in 0..<game.map.width {
          print(game.map[Position(x, y)], terminator: "")
        }
        print()
      }
      print()
    }

    var playerPosition: Position? = nil
    game.map.forEach { p, c in
      if c == "@" {
        playerPosition = p
      }
    }

    let operations = push(&game, playerPosition!, instruction)
    for operation in operations {
      game.map[operation.to] = game.map[operation.from]
      game.map[operation.from] = "."
    }
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
  let operation = Operation(from: from, to: to)

  // Cannot move
  if !game.map.inBounds(to) || game.map[to] == "#" {
    return []
  }

  // Ok to move!
  if game.map[to] == "." {
    return [operation]
  }

  // Only boxes left
  var compoundPush = [to]
  if direction.dy != 0 && game.map[to] == "[" {
    compoundPush += [to + Direction(1, 0)]
  }

  if direction.dy != 0 && game.map[to] == "]" {
    compoundPush += [to + Direction(-1, 0)]
  }

  let operations = compoundPush.map { to in push(&game, to, direction) }
  guard operations.allSatisfy({ $0.count > 0 }) else {
    return []
  }

  var result = operations.reduce(into: OrderedSet<Operation>([])) { $0.append(contentsOf: $1) }
  result.append(contentsOf: [operation])
  return result
}
