import Foundation
import Utils

public struct Solution: Day {
  public static func solvePart1(_ input: String) async -> Int {
    let (antennaGroups, gridSize) = parseAntennaMap(input)
    return countAntinodes(antennaGroups, gridSize, 1, 1)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let (antennaGroups, gridSize) = parseAntennaMap(input)
    return countAntinodes(antennaGroups, gridSize, 0, max(gridSize.0, gridSize.1))
  }
}

func parseAntennaMap(_ input: String) -> ([[Position]], (Int, Int)) {
  let grid = input.split(separator: "\n").map { line in
    line.map { $0 }
  }

  var antennaPositions: [Character: [Position]] = [:]

  for x in 0..<grid.count {
    for y in 0..<grid[0].count {
      if grid[x][y] != "." {
        var positions = antennaPositions[grid[x][y]] ?? []
        positions.append(Position(x, y))
        antennaPositions[grid[x][y]] = positions
      }
    }
  }

  return (antennaPositions.map { (_, positions) in positions }, (grid.count, grid[0].count))
}

func countAntinodes(
  _ antennaGroups: [[Position]], _ gridSize: (Int, Int), _ minDistance: Int, _ maxDistance: Int
) -> Int {
  let (width, height) = gridSize

  var antinodes = Set<Position>()

  for positions in antennaGroups {
    for (p1, p2) in positions.flatMap({ p1 in positions.filter { $0 != p1 }.map { (p1, $0) } }) {
      for i in minDistance...maxDistance {
        let antinodePosition = p2 + (p2 - p1) * i
        if antinodePosition.x < 0 || antinodePosition.x >= width || antinodePosition.y < 0
          || antinodePosition.y >= height
        {
          break
        }

        antinodes.insert(antinodePosition)
      }
    }
  }

  return antinodes.count
}
