import Foundation
import Utils

let shouldSolveExamplesOnly = false

func parseGame(_ gameString: String.SubSequence) -> Game? {
  let rows = gameString.split(separator: "\n")
  if let aMatch = String(rows[0]).firstMatch(of: #/Button A: X\+(?<x>[0-9]+), Y\+(?<y>[0-9]+)/#),
    let bMatch = String(rows[1]).firstMatch(of: #/Button B: X\+(?<x>[0-9]+), Y\+(?<y>[0-9]+)/#),
    let prizeMatch = String(rows[2]).firstMatch(of: #/Prize: X=(?<x>[0-9]+), Y=(?<y>[0-9]+)/#)
  {

    return Game(
      a: Direction(Int(aMatch.output.x)!, Int(aMatch.output.y)!),
      b: Direction(Int(bMatch.output.x)!, Int(bMatch.output.y)!),
      prize: Position(Int(prizeMatch.output.x)!, Int(prizeMatch.output.y)!))
  }

  return nil
}

func parseInput(_ input: String) -> [Game] {
  return input.split(separator: "\n\n").compactMap { gameString in
    parseGame(gameString)
  }
}

struct Game {
  let a: Direction
  let b: Direction
  let prize: Position
}

func solve(_ game: Game) -> Int? {
  let ka = Double(game.a.dy) / Double(game.a.dx)
  let kb = Double(game.b.dy) / Double(game.b.dx)

  let ca: Double = 0.0
  let cb: Double = Double(game.prize.y) - Double(game.prize.x) * kb
  let x = abs((cb - ca) / (ka - kb))
  let numA = Int(round(x / Double(game.a.dx)))
  let numB = Int(round((Double(game.prize.x) - x) / Double(game.b.dx)))

  if Position(0, 0) + game.a * numA + game.b * numB == game.prize {
    return numA * 3 + numB
  }

  return nil
}

public struct Solution: Day {
  public static var facitPart1: Int = 39996

  public static var facitPart2: Int = 73_267_584_326_867

  public static var onlySolveExamples: Bool { shouldSolveExamplesOnly }

  public static func solvePart1(_ input: String) async -> Int {
    parseInput(input).compactMap { solve($0) }.reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
    parseInput(input).map {
      Game(
        a: $0.a,
        b: $0.b,
        prize: $0.prize + Direction(10_000_000_000_000, 10_000_000_000_000))
    }.compactMap { solve($0) }.reduce(0, +)
  }
}
