import Foundation
import Utils

let shouldSolveExamplesOnly = false

let width = 101
let height = 103

struct Robot {
  let p: Position
  let v: Direction
}

func parseInput(_ input: String) -> [Robot] {
  input.matches(of: #/p=(?<x>[0-9]+),(?<y>[0-9]+) v=(?<dx>[\-0-9]+),(?<dy>[\-0-9]+)/#)
    .map {
      Robot(
        p: Position(Int($0.output.x)!, Int($0.output.y)!),
        v: Direction(Int($0.output.dx)!, Int($0.output.dy)!))
    }
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool { shouldSolveExamplesOnly }

  public static func solvePart1(_ input: String) async -> Int {
    let positions = parseInput(input)
      .map {
        $0.p + $0.v * 100
      }.map {
        Position(($0.x % width + width) % width, ($0.y % height + height) % height)
      }

    let quadrants = [
      (0, 0, width / 2, height / 2), (width / 2 + 1, 0, width, height / 2),
      (0, height / 2 + 1, width / 2, height), (width / 2 + 1, height / 2 + 1, width, height),
    ]

    return quadrants.map({ quad in
      positions.filter { pos in
        pos.x >= quad.0 && pos.x < quad.2 && pos.y >= quad.1 && pos.y < quad.3
      }.count
    }).reduce(1, *)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let robots = parseInput(input)
    for i in 0..<10000 {
      let positions =
        robots
        .map {
          $0.p + $0.v * i
        }.map {
          Position(($0.x % width + width) % width, ($0.y % height + height) % height)
        }

      if positions.first { p in
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10].allSatisfy { i in
          positions.contains(p + Direction(0, i))
        }
      } != nil {
        for y in 0..<height {
          for x in 0..<width {
            if positions.contains(Position(x, y)) {
              print("#", terminator: "")
            } else {
              print(".", terminator: "")
            }
          }
          print()
        }

        return i
      }
    }
    return 0
  }
}
