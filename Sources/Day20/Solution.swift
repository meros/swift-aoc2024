import Foundation
import Utils

let example = false
let minSaved = 100

public class Solution: Day {
  public static let facitPart1 = 1497

  public static let facitPart2 = 1030809

  public static var onlySolveExamples: Bool = example

  public static func solvePart1(_ input: String) -> Int {
    let (map, start, goal) = parseRaceMap(input)

    return solve(map, start, goal, 2)!
  }

  public static func solvePart2(_ input: String) -> Int {
    let (map, start, goal) = parseRaceMap(input)

    return solve(map, start, goal, 20)!
  }
}

func parseRaceMap(_ input: String) -> (map: Grid<Character>, start: Position, goal: Position) {
  let grid = Grid(input.parseGrid())

  let start = grid.first(where: { $0.1 == "S" })!.0
  let goal = grid.first(where: { $0.1 == "E" })!.0

  return (grid, start, goal)
}

extension Position {
  public func manhattanDistance(to other: Position) -> Int {
    abs(x - other.x) + abs(y - other.y)
  }
}

class RaceGraph: Graph {
  func neighbors(of state: Position, each: (Position, Int) -> Void) {
    if grid[state] != "#" {
      Direction.allDirections.forEach {
        let newState = state + $0
        if grid.inBounds(newState) && grid[newState] != "#" {
          each(newState, 1)
        }
      }
    }
  }

  func heuristic(from state: Position, to goal: Position) -> Int {
    state.manhattanDistance(to: goal)
  }

  typealias State = Position
  typealias Cost = Int

  let grid: Grid<Character>
  var disallowedCheats: [Position: Set<Position>] = [:]

  public init(grid: Grid<Character>) {
    self.grid = grid
  }
}

func solve(_ map: Grid<Character>, _ start: Position, _ goal: Position, _ maxCheatDistance: Int)
  -> Int?
{
  let graph = RaceGraph(grid: map)

  let baselineResult =
    graph.shortestPath(from: start, to: goal)

  guard let baseLineCost = baselineResult.cost else {
    return nil
  }

  var costs: [Position: (fromStart: Int, toGoal: Int)] = [:]

  var state: Position? = goal
  var cost = 0
  while let innerState = state {
    costs[innerState] = (fromStart: baseLineCost - cost, toGoal: cost)
    cost += 1

    if innerState == start {
      break
    }

    state = baselineResult.visited[innerState]
  }

  var count = 0
  for y in 0..<map.height {
    for x in 0..<map.width {
      let cheatFrom = Position(x, y)
      if map[cheatFrom] == "#" {
        continue
      }

      for dy in -maxCheatDistance...maxCheatDistance {
        for dx in -maxCheatDistance...maxCheatDistance {
          let cheatTo = cheatFrom + Position(dx, dy)

          let manhattanDistance = cheatFrom.manhattanDistance(to: cheatTo)
          if manhattanDistance == 0 || manhattanDistance > maxCheatDistance {
            continue
          }

          if map.inBounds(cheatTo) && map[cheatTo] != "#" {
            let cost =
              costs[cheatFrom]!.fromStart + costs[cheatTo]!.toGoal + abs(dx) + abs(dy)
            let saved = baseLineCost - cost

            if saved >= minSaved {
              count += 1
            }
          }

        }
      }
    }
  }

  return count
}
