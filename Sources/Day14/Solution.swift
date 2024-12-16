import Foundation
import Utils

let shouldSolveExamplesOnly = false

private let floorWidth = 101
private let floorHeight = 103

struct SecurityRobot {
  let position: Position
  let velocity: Direction
}

private func parseRobots(_ input: String) -> [SecurityRobot] {
  input.matches(of: #/p=(?<x>[0-9]+),(?<y>[0-9]+) v=(?<dx>[\-0-9]+),(?<dy>[\-0-9]+)/#)
    .map {
      SecurityRobot(
        position: Position(Int($0.output.x)!, Int($0.output.y)!),
        velocity: Direction(Int($0.output.dx)!, Int($0.output.dy)!)
      )
    }
}

private func calculateRobotPositions(_ robots: [SecurityRobot], at time: Int) -> [Position] {
  robots.map { robot in
    let newPos = robot.position + robot.velocity * time
    return Position(
      (newPos.x % floorWidth + floorWidth) % floorWidth,
      (newPos.y % floorHeight + floorHeight) % floorHeight
    )
  }
}

private func countRobotsInQuadrants(_ positions: [Position]) -> [Int] {
  let quadrants = [
    (0, 0, floorWidth / 2, floorHeight / 2),
    (floorWidth / 2 + 1, 0, floorWidth, floorHeight / 2),
    (0, floorHeight / 2 + 1, floorWidth / 2, floorHeight),
    (floorWidth / 2 + 1, floorHeight / 2 + 1, floorWidth, floorHeight),
  ]

  return quadrants.map { quad in
    positions.filter { pos in
      pos.x >= quad.0 && pos.x < quad.2 && pos.y >= quad.1 && pos.y < quad.3
    }.count
  }
}

public struct Solution: Day {
  public static var facitPart1: Int = 229_421_808

  public static var facitPart2: Int = 6577

  public static var onlySolveExamples: Bool { shouldSolveExamplesOnly }

  public static func solvePart1(_ input: String) async -> Int {
    let robots = parseRobots(input)
    let positions = Array(calculateRobotPositions(robots, at: 100))

    for y in 0..<floorHeight {
      for x: Int in 0..<floorWidth {
        let count = positions.count { $0 == Position(x, y) }
        print(count, terminator: "")
      }
      print()
    }

    return countRobotsInQuadrants(positions).reduce(1, *)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let robots = parseRobots(input)

    for time in 0..<floorHeight * floorWidth {
      let positions = Set(calculateRobotPositions(robots, at: time))

      // Check for vertical line of 10 robots (Christmas tree pattern)
      if positions.contains(where: { basePos in
        (0...9).allSatisfy { offset in
          positions.contains(basePos + Direction(0, offset))
        }
      }) {
        return time
      }
    }
    return 0
  }
}
