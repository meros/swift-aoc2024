import Foundation
import Utils

func parseInput(_ input: String) -> Grid<Int> {
  Grid(input.parseGrid().compactMap { $0.compactMap { Int(String($0)) } })
}

func traverseTrail(
  _ grid: Grid<Int>,
  from current: Position,
  trailhead: Position,
  onPeakReached: (_ trailhead: Position, _ peak: Position) -> Void
) {
  guard grid[current] < 9 else {
    onPeakReached(trailhead, current)
    return
  }

  Direction.allDirections
    .map { current + $0 }
    .filter { grid.inBounds($0) && grid[$0] == grid[current] + 1 }
    .forEach { traverseTrail(grid, from: $0, trailhead: trailhead, onPeakReached: onPeakReached) }
}

public struct Solution: Day {
  public static var facitPart1: Int = 733

  public static var facitPart2: Int = 1514

  public static var onlySolveExamples: Bool { false }

  public static func solvePart1(_ input: String) async -> Int {
    let grid = parseInput(input)
    var trailheadToPeaks: [Position: Set<Position>] = [:]

    grid.forEach { position, value in
      guard value == 0 else { return }
      traverseTrail(grid, from: position, trailhead: position) { trailhead, peak in
        trailheadToPeaks[trailhead, default: []].insert(peak)
      }
    }

    return trailheadToPeaks.values.map(\.count).reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let grid = parseInput(input)
    var trailheadToPathCount: [Position: Int] = [:]

    grid.forEach { position, value in
      guard value == 0 else { return }
      traverseTrail(grid, from: position, trailhead: position) { _, _ in
        trailheadToPathCount[position, default: 0] += 1
      }
    }

    return trailheadToPathCount.values.reduce(0, +)
  }
}
