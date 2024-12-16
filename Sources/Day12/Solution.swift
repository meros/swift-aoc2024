import Foundation
import Utils

public struct Solution: Day {
  public static var facitPart1: Int = 1_424_006

  public static var facitPart2: Int = 858684

  public static var onlySolveExamples: Bool { false }

  public static func solvePart1(_ input: String) async -> Int {
    let garden = parseGardenMap(input)
    return garden.sumRegionValues { $0.count * countFenceSides($0) }
  }

  public static func solvePart2(_ input: String) async -> Int {
    let garden = parseGardenMap(input)
    return garden.sumRegionValues { $0.count * countFenceSides($0, mergeContinousSides: true) }
  }
}

let directions = Direction.allDirections

func parseGardenMap(_ input: String) -> Grid<Int> {
  Grid(
    input.parseGrid().compactMap {
      $0.compactMap { Int($0.uppercased().unicodeScalars.first!.value - Unicode.Scalar("A").value) }
    })
}

func findRegion(_ position: Position, _ garden: Grid<Int>) -> Set<Position> {
  var region: Set<Position> = [position]

  var toCheck = [position]
  while let current = toCheck.popLast() {
    toCheck.append(
      contentsOf:
        directions
        .map { current + $0 }
        .filter { garden.inBounds($0) && garden[$0] == garden[position] && !region.contains($0) })

    region.formUnion(toCheck)
  }

  return region
}

struct FenceSegment: Hashable {
  let position: Position
  let direction: Direction

  init(_ position: Position, _ direction: Direction) {
    self.position = position
    self.direction = direction
  }
}

func countFenceSides(_ region: Set<Position>, mergeContinousSides: Bool = false) -> Int {
  let allFenceSegments = region.flatMap { pos in
    directions
      .filter { !region.contains(pos + $0) }
      .map { FenceSegment(pos, $0) }
  }

  if !mergeContinousSides {
    return allFenceSegments.count
  }

  return allFenceSegments.filter {
    !allFenceSegments.contains(
      FenceSegment($0.position + $0.direction.rotateRight(), $0.direction))
  }.count
}

extension Grid<Int> {
  func sumRegionValues(_ valueOfRegion: (_ region: Set<Position>) -> Int) -> Int {
    var totalValue = 0
    var visited: Set<Position> = []
    self.forEach {
      pos, _ in
      guard !visited.contains(pos) else { return }
      let region = findRegion(pos, self)
      totalValue += valueOfRegion(region)
      visited.formUnion(region)
    }

    return totalValue
  }
}
