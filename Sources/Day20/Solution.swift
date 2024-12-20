import Foundation
import Utils

private let minimumSaving = 100

public class Solution: Day {
  public static var onlySolveExamples: Bool { false }
  public static var facitPart1: Int = 1497
  public static var facitPart2: Int = 1_030_809

  public static func solvePart1(_ input: String) async -> Int {
    let track = parseRaceTrack(input)
    return findShortcuts(track, maxJump: 2) ?? 0
  }

  public static func solvePart2(_ input: String) async -> Int {
    let track = parseRaceTrack(input)
    return findShortcuts(track, maxJump: 20) ?? 0
  }
}

extension Position {
  fileprivate func manhattanDistance(to other: Position) -> Int {
    abs(x - other.x) + abs(y - other.y)
  }
}

private struct RaceTrack {
  let grid: Grid<Character>
  let start: Position
  let finish: Position
}

private struct ShortcutFinder: Graph {
  typealias State = Position
  typealias Cost = Int

  let track: Grid<Character>

  func neighbors(of position: Position, each: (Position, Int) -> Void) {
    if track[position] != "#" {
      Direction.allDirections.forEach {
        let next = position + $0
        if track.inBounds(next) && track[next] != "#" {
          each(next, 1)
        }
      }
    }
  }

  func heuristic(from position: Position, to target: Position) -> Int {
    position.manhattanDistance(to: target)
  }
}

private func findShortcuts(_ track: RaceTrack, maxJump: Int) -> Int? {
  let pathFinder = ShortcutFinder(track: track.grid)
  let basePath = pathFinder.shortestPath(from: track.start, to: track.finish)

  guard let baseDistance = basePath.cost else { return nil }

  var costToGoalGrid = Grid<Int?>(
    Array(
      repeating: Array(repeating: nil, count: track.grid.width), count: track.grid.height))

  var startPositions = [(Position, Int)]()

  var current: Position? = track.finish
  var distance = 0
  while let pos = current {
    startPositions.append((pos, baseDistance - distance))
    costToGoalGrid[pos] = distance

    distance += 1
    if pos == track.start { break }
    current = basePath.visited[pos]
  }

  var validShortcuts = 0
  startPositions.forEach { from, startCost in
    let mj = max(0, min(maxJump, baseDistance - startCost - minimumSaving))
    for dy in max(-mj, -from.y)...min(mj, track.grid.height - 1 - from.y) {

      for dx in max(
        -(mj - abs(dy)), -from.x)...min(mj - abs(dy), track.grid.width - 1 - from.x)
      {
        let to = from + Direction(dx, dy)
        guard let targetCost = costToGoalGrid[to] else { continue }

        let jumpCost = abs(dx) + abs(dy)
        let shortcutCost = startCost + targetCost + jumpCost
        let saved = baseDistance - shortcutCost

        if saved >= minimumSaving {
          validShortcuts += 1
        }
      }
    }
  }

  return validShortcuts
}

private func parseRaceTrack(_ input: String) -> RaceTrack {
  let grid = Grid(input.parseGrid())
  let start = grid.first { $0.1 == "S" }!.0
  let finish = grid.first { $0.1 == "E" }!.0
  return RaceTrack(grid: grid, start: start, finish: finish)
}
