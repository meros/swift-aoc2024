import Foundation
import Utils

func parseInput(_ input: String) -> Grid<Int> {
  Grid(
    input.parseGrid().map {
      $0.map {
        Int(String($0))!
      }
    })
}

func traverseTrail(
  _ grid: Grid<Int>,
  _ current: Position,
  _ trailhead: Position,
  _ onPeakReached: (_ peak: Position, _ trailhead: Position) -> Void
) {
  if grid[current] == 9 {
    onPeakReached(trailhead, current)
  } else {
    Direction.allDirections
      .map { current + $0 }
      .filter { grid.inBounds($0) && grid[$0] == grid[current] + 1 }
      .forEach { traverseTrail(grid, $0, trailhead, onPeakReached) }
  }
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let grid = parseInput(input)
    
    var trailheadToPeaksMap: [Position: Set<Position>] = [:]

    grid.forEach {
      if $1 == 0 {
        traverseTrail(grid, $0, $0) { trailheadToPeaksMap[$0, default: []].insert($1) }
      }
    }

    return trailheadToPeaksMap.values.map { $0.count }.reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let grid = parseInput(input)

    var trailheadToPathCountMap: [Position: Int] = [:]

    grid.forEach {
      if $1 == 0 {
        traverseTrail(grid, $0, $0) { trailheadToPathCountMap[$1, default: 0] += 1 }
      }
    }

    return trailheadToPathCountMap.values.reduce(0, +)
  }
}
