import Foundation
import Utils

public struct Solution: Day {
  public static var facitPart1: Int = 320

  public static var facitPart2: Int = 1157

  public static func solvePart1(_ input: String) async -> Int {
    let (antennaGroups, grid) = parseAntennaMap(input)
    return countAntinodes(antennaGroups, grid, 1, 1)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let (antennaGroups, grid) = parseAntennaMap(input)
    return countAntinodes(antennaGroups, grid, 0, max(grid.width, grid.height))
  }
}

func parseAntennaMap(_ input: String) -> ([[Position]], Grid<Character>) {
  let characters = input.parseGrid().map { $0.map { Character(String($0)) } }
  let grid = Grid(characters)

  var antennaPositions: [Character: [Position]] = [:]

  // Use Grid dimensions instead of manual counting
  for x in 0..<grid.width {
    for y in 0..<grid.height {
      if grid.values[x][y] != "." {
        var positions = antennaPositions[grid.values[x][y]] ?? []
        positions.append(Position(x, y))
        antennaPositions[grid.values[x][y]] = positions
      }
    }
  }

  return (antennaPositions.map { $0.value }, grid)
}

func countAntinodes(
  _ antennaGroups: [[Position]],
  _ grid: Grid<Character>,
  _ minDistance: Int,
  _ maxDistance: Int
) -> Int {
  var antinodes = Set<Position>()

  for positions in antennaGroups {
    for (p1, p2) in positions.flatMap({ p1 in
      positions.filter { $0 != p1 }.map { (p1, $0) }
    }) {
      for i in minDistance...maxDistance {
        let antinodePosition = p2 + (p2 - p1) * i

        if !grid.inBounds(antinodePosition) {
          break
        }

        antinodes.insert(antinodePosition)
      }
    }
  }

  return antinodes.count
}
