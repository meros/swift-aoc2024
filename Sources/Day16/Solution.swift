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
    return lhs.heuristicValue < rhs.heuristicValue
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(pos)
    hasher.combine(direction)
  }

  static func == (lhs: State, rhs: State) -> Bool {
    return
      lhs.pos == rhs.pos && lhs.direction == rhs.direction
  }

  static private func heuristic(goal: Position, pos: Position, cost: Int) -> Int {
    let manhattanDistance = abs(goal.x - pos.x) + abs(goal.y - pos.y)

    let generalDirectionToGoal = Direction(
      (goal.x - pos.x).signum(), (goal.y - pos.y).signum())

    let turns = (generalDirectionToGoal.dx != 0 && generalDirectionToGoal.dy != 0) ? 1 : 0

    return manhattanDistance + turns * 1000 + cost
  }

  init(pos: Position, direction: Direction, goal: Position, cost: Int) {
    self.pos = pos
    self.direction = direction
    self.goal = goal
    self.cost = cost

    self.heuristicValue = State.heuristic(goal: goal, pos: pos, cost: cost)
  }

  // Hashed state
  let pos: Position
  let direction: Direction

  // Full state
  let goal: Position
  let cost: Int

  // Calculated value 
  let heuristicValue: Int
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

    var openBacktrackStates = Set([
      endState
    ])
    var closedBacktrackState = Set<State>([])

    while let backtrackState = openBacktrackStates.popFirst() {
      closedBacktrackState.insert(backtrackState)
      if backtrackState == startState {
        continue
      }

      openBacktrackStates.formUnion(
        getPrevStates(backtrackState).filter {
          if closedBacktrackState.contains($0) {
            return false
          }

          guard let index = closedList.firstIndex(of: $0) else { return false }
          return closedList[index].cost == $0.cost
        })
    }

    return Set(closedBacktrackState.map { $0.pos }).count
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
      direction: fullState.direction.rotateRight(),

      goal: fullState.goal,
      cost: fullState.cost + 1000),
    State(
      pos: fullState.pos,
      direction: fullState.direction.rotateLeft(),

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
      direction: fullState.direction.rotateRight(),

      goal: fullState.goal,
      cost: fullState.cost - 1000),
    State(
      pos: fullState.pos,
      direction: fullState.direction.rotateLeft(),

      goal: fullState.goal,
      cost: fullState.cost - 1000),
  ]
}
