import Collections
import Foundation
import Utils

struct Maze {
  let map: Grid<Bool>
  let startPos: Position
  let endPos: Position
}

func parseMaze(_ input: String) -> Maze {
  let map: Grid<Bool> = Grid(
    input.parseGrid().map {
      $0.map {
        switch $0 {
        case "#": return false
        default: return true
        }
      }
    })

  let charMap: Grid<Character> = Grid(input.parseGrid())
  let startPos = charMap.first { pos, c in
    c == "S"
  }!.0
  let endPos = charMap.first { pos, c in
    c == "E"
  }!.0

  return Maze(map: map, startPos: startPos, endPos: endPos)
}

struct State: Comparable, Hashable, Equatable {
  static func < (lhs: State, rhs: State) -> Bool {
    lhs.heuristic() < rhs.heuristic()
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(pos)
    hasher.combine(direction)
  }

  static func == (lhs: State, rhs: State) -> Bool {
    return
      lhs.pos == rhs.pos && lhs.direction == rhs.direction
  }

  private func heuristic() -> Int {
    let manhattanDistance = abs(goal.x - pos.x) + abs(goal.y - pos.y)

    let generalDirectionToGoal = Direction(
      (goal.x - pos.x).signum(), (goal.y - pos.y).signum())

    var turns = 0
    // Diagonal?
    if generalDirectionToGoal.dx != 0 && generalDirectionToGoal.dy != 0 {
      // Need to turn once to get there
      turns += 1
      // Might need to turn once to get going
      turns +=
        (direction == Direction(0, generalDirectionToGoal.dy)
          || direction == Direction(generalDirectionToGoal.dx, 0)) ? 0 : 1
    } else {
      // 180 needed to get going?
      turns += (direction == generalDirectionToGoal * -1) ? 2 : 0
      // 90 degrees needed to get going?
      turns += abs(direction.dx) == abs(generalDirectionToGoal.dy) ? 1 : 0
    }

    return manhattanDistance + turns * 1000 + cost
  }

  // Hashed state
  let pos: Position
  let direction: Direction

  // Full state
  let goal: Position
  let cost: Int
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let maze: Maze = parseMaze(input)

    return solveMazeGetClosedList(maze).first {
      $0.pos == maze.endPos
    }!.cost
  }

  public static func solvePart2(_ input: String) async -> Int {
    let maze: Maze = parseMaze(input)

    let closedList = solveMazeGetClosedList(maze)

    // Backtrack from goal to start, finding all optimal paths
    let endState = closedList.first { $0.pos == maze.endPos }!
    let startState = State(
      pos: maze.startPos, direction: Direction(1, 0), goal: maze.endPos, cost: 0)

    var backtrackedStates = Set([
      endState
    ])

    while !backtrackedStates.contains(startState) {
      let newBacktrackedStates = backtrackedStates.flatMap {
        getPrevStates($0).filter {
          guard let index = closedList.firstIndex(of: $0) else { return false }
          return closedList[index].cost == $0.cost
        }
      }

      backtrackedStates.formUnion(newBacktrackedStates)
    }

    return Set(backtrackedStates.map { $0.pos }).count
  }
}

func solveMazeGetClosedList(_ maze: Maze) -> Set<State> {
  var closedList = Set<State>([])
  var openList = Heap<State>([
    State(
      pos: maze.startPos, direction: Direction(1, 0), goal: maze.endPos, cost: 0)
  ])

  while let state = openList.popMin() {
    closedList.insert(state)
    if state.pos == state.goal {
      break
    }

    openList.insert(
      contentsOf: getNextStates(state).filter({ maze.map[$0.pos] && !closedList.contains($0) }))
  }

  return closedList
}

func getNextStates(_ fullState: State) -> [State] {
  [
    State(
      pos: fullState.pos + fullState.direction,
      direction: fullState.direction,

      goal: fullState.goal,
      cost: fullState.cost + 1),
    State(
      pos: fullState.pos,
      direction: Direction.allDirections.next(fullState.direction),

      goal: fullState.goal,
      cost: fullState.cost + 1000),
    State(
      pos: fullState.pos,
      direction: Direction.allDirections.prev(fullState.direction),

      goal: fullState.goal,
      cost: fullState.cost + 1000),
  ]
}

func getPrevStates(_ fullState: State) -> [State] {
  [
    State(
      pos: fullState.pos - fullState.direction,
      direction: fullState.direction,

      goal: fullState.goal,
      cost: fullState.cost - 1),
    State(
      pos: fullState.pos,
      direction: Direction.allDirections.next(fullState.direction),

      goal: fullState.goal,
      cost: fullState.cost - 1000),
    State(
      pos: fullState.pos,
      direction: Direction.allDirections.prev(fullState.direction),

      goal: fullState.goal,
      cost: fullState.cost - 1000),
  ]
}
