import Foundation
import Utils

func parseGardenMap(_ input: String) -> Grid<Int> {
  Grid(
    input.parseGrid().compactMap {
      $0.compactMap {
        guard $0.isLetter else { return nil }
        return Int($0.uppercased().unicodeScalars.first!.value - Unicode.Scalar("A").value)
      }
    }
  )
}

func findRegion(_ position: Position, _ garden: Grid<Int>) -> Set<Position> {
  let plantType = garden[position]
  var region: Set<Position> = [position]
  var toCheck = [position]

  while let current = toCheck.popLast() {
    let adjacent = Direction.allDirections
      .map { current + $0 }
      .filter { garden.inBounds($0) && garden[$0] == plantType && !region.contains($0) }

    region.formUnion(adjacent)
    toCheck.append(contentsOf: adjacent)
  }

  return region
}

private func nextFenceDirection(_ current: Direction) -> Direction {
  switch current {
  case .up: return .right
  case .right: return .down
  case .down: return .left
  case .left: return .up
  default: return current
  }
}

struct FenceSegment: Hashable {
  let position: Position
  let direction: Direction

  init(_ position: Position, _ direction: Direction) {
    self.position = position
    self.direction = direction
  }
}

func countFenceSides(_ region: Set<Position>, onlyCorners: Bool = false) -> Int {
  let allFenceSegments = region.flatMap { position in
    Direction.allDirections.filter { direction in
      let adjacent = position + direction
      return !region.contains(adjacent)
    }.map { direction in
      FenceSegment(position, direction)
    }
  }

  if !onlyCorners {
    return allFenceSegments.count
  }

  return allFenceSegments.filter {
    fenceSegment in
    !allFenceSegments.contains(
      FenceSegment(
        fenceSegment.position + nextFenceDirection(fenceSegment.direction), fenceSegment.direction))
  }.count
}

extension Grid<Int> {
  func forEachRegion(_ body: (_ region: Set<Position>) -> Void) {
    var visited: Set<Position> = []

    self.forEach {
      pos, _ in
      guard !visited.contains(pos) else { return }
      let region = findRegion(pos, self)
      body(region)
      visited.formUnion(region)
    }
  }
}
public struct Solution: Day {
  public static var onlySolveExamples: Bool { false }

  public static func solvePart1(_ input: String) async -> Int {
    let garden = parseGardenMap(input)

    var totalFenceCost = 0

    garden.forEachRegion { region in
      let area = region.count
      let perimeter = countFenceSides(region)

      totalFenceCost += area * perimeter
    }

    return totalFenceCost
  }

  public static func solvePart2(_ input: String) async -> Int {
    let garden = parseGardenMap(input)

    var totalFenceCost = 0

    garden.forEachRegion { region in
      let area = region.count
      let sides = countFenceSides(region, onlyCorners: true)

      totalFenceCost += area * sides
    }

    return totalFenceCost
  }
}
