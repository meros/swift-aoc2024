import Foundation
import Utils

let example = false
let minSaved = example ? 50 : 100

public class Solution: Day {
  public static var onlySolveExamples: Bool = example

  public static func solvePart1(_ input: String) -> Int {
    let (map, start, goal) = parseRaceMap(input)
    let graph = SuperCheatRaceGraph(grid: map, maxCheatLength: 2)

    let baselineResult =
      graph.shortestPath(
        from: RaceState(pos: start, cheats: 0), to: RaceState(pos: goal, cheats: 0))

    guard let baseLineCost = baselineResult.cost else {
      return -1
    }

    var saved = baseLineCost
    while true {
      let cheatResult = graph.shortestPath(
        from: RaceState(pos: start, cheats: 0), to: RaceState(pos: goal, cheats: 1))

      guard let cheatCost = cheatResult.cost else {
        break
      }

      let cheatPoint = findCheatPoint(
        map: map, visited: cheatResult.visited, start: RaceState(pos: start, cheats: 0),
        goal: RaceState(pos: goal, cheats: 1))

      guard let cheatPoint = cheatPoint else {
        break
      }

      print("Cheat cost: \(cheatCost), saved: \(baseLineCost - cheatCost)")
      saved = baseLineCost - cheatCost
      if saved < minSaved {
        break
      }

      graph.disallowedCheats[cheatPoint.start, default: []].insert(cheatPoint.end)
    }
    if example {
      for y in 0..<map.height {
        for x in 0..<map.width {
          print(map[Position(x, y)], terminator: "")
        }
        print()
      }
    }

    return graph.disallowedCheats.reduce(0) { $0 + $1.value.count }
  }

  public static func solvePart2(_ input: String) -> Int {
    let (map, start, goal) = parseRaceMap(input)
    let graph = SuperCheatRaceGraph(grid: map, maxCheatLength: 20)

    let baselineResult =
      graph.shortestPath(
        from: RaceState(pos: start, cheats: 0), to: RaceState(pos: goal, cheats: 0))

    guard let baseLineCost = baselineResult.cost else {
      return -1
    }

    var saved = baseLineCost
    while true {

      let cheatResult = graph.shortestPath(
        from: RaceState(pos: start, cheats: 0), to: RaceState(pos: goal, cheats: 1))

      guard let cheatCost = cheatResult.cost else {
        break
      }

      let cheatPoint = findCheatPoint(
        map: map, visited: cheatResult.visited, start: RaceState(pos: start, cheats: 0),
        goal: RaceState(pos: goal, cheats: 1))

      guard let cheatPoint = cheatPoint else {
        break
      }

      print("Cheat cost: \(cheatCost), saved: \(baseLineCost - cheatCost)")      
      saved = baseLineCost - cheatCost
      if saved < minSaved {
        break
      }

      graph.disallowedCheats[cheatPoint.start, default: []].insert(cheatPoint.end)
    }

    if example {
      for y in 0..<map.height {
        for x in 0..<map.width {
          print(map[Position(x, y)], terminator: "")
        }
        print()
      }
    }

    return graph.disallowedCheats.reduce(0) { $0 + $1.value.count }
  }
}

func findCheatPoint(
  map: Grid<Character>, visited: [SuperCheatRaceGraph.State: SuperCheatRaceGraph.State],
  start: RaceState,
  goal: RaceState
) -> (start: Position, end: Position)? {

  var current: RaceState? = goal
  while current != start {

    guard let innerCurrent = current else {
      return nil
    }

    guard let last = visited[innerCurrent] else {
      return nil
    }

    if last.cheats < innerCurrent.cheats {
      return (start: last.pos, end: innerCurrent.pos)
    }

    current = last
  }

  return nil
}

func parseRaceMap(_ input: String) -> (map: Grid<Character>, start: Position, goal: Position) {
  let grid = Grid(input.parseGrid())

  let start = grid.first(where: { $0.1 == "S" })!.0
  let goal = grid.first(where: { $0.1 == "E" })!.0

  return (grid, start, goal)
}

struct RaceState: Hashable {
  let pos: Position
  let cheats: Int
}

extension Position {
  public func manhattanDistance(to other: Position) -> Int {
    abs(x - other.x) + abs(y - other.y)
  }
}

class SuperCheatRaceGraph: Graph {
  func neighbors(of state: RaceState, each: (RaceState, Int) -> Void) {
    // From open cells to open cells (always allowed)
    if grid[state.pos] != "#" {
      Direction.allDirections.forEach {
        let newPos = state.pos + $0
        if grid.inBounds(newPos) && grid[newPos] != "#" {
          each(RaceState(pos: newPos, cheats: state.cheats), 1)
        }
      }
    }

    // From open cells with no cheats, cheating allowed
    if state.cheats == 0 {
      for y in max(
        (state.pos.y - maxCheatLength), 0)...min((state.pos.y + maxCheatLength), grid.height-1)
      {
        for x in max(
          (state.pos.x - maxCheatLength), 0)...min((state.pos.x + maxCheatLength), grid.width-1)
        {
          let endPos = Position(x, y)

          // Cheating too far away
          let cheatDistance = state.pos.manhattanDistance(to: endPos)
          if cheatDistance > maxCheatLength || cheatDistance == 0 {
            continue
          }

          if grid[endPos] == "#" {
            continue
          }

          // This cheat is not allowed
          if disallowedCheats[state.pos, default: []].contains(endPos) {
            continue
          }

          let cheatState = State(pos: endPos, cheats: 1)
          each(cheatState, cheatDistance)
        }
      }
    }

    // From open cells with cheats
    if state.cheats == 1 {
      Direction.allDirections.forEach {
        let newPos = state.pos + $0
        if grid.inBounds(newPos) && grid[newPos] != "#" {
          each(RaceState(pos: newPos, cheats: state.cheats), 1)
        }
      }
    }
  }

  func heuristic(from state: RaceState, to goal: RaceState) -> Int {
    if goal.cheats < state.cheats {
      return 10000
    }

    return state.pos.manhattanDistance(to: goal.pos)
  }

  typealias State = RaceState
  typealias Cost = Int

  let grid: Grid<Character>
  let maxCheatLength: Int
  var disallowedCheats: [Position: Set<Position>] = [:]

  public init(grid: Grid<Character>, maxCheatLength: Int) {
    self.grid = grid
    self.maxCheatLength = maxCheatLength
  }
}
