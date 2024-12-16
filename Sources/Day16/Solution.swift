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

struct FullState: Comparable, Hashable, Equatable {
  static func < (lhs: FullState, rhs: FullState) -> Bool {
    lhs.heuristic() < rhs.heuristic()
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(pos)
    hasher.combine(direction)
  }

  static func == (lhs: FullState, rhs: FullState) -> Bool {
    return
      lhs.pos == rhs.pos && lhs.direction == rhs.direction
  }

  private func heuristic() -> Int {
    // Manhattan distance
    let distance = abs(goal.x - pos.x) + abs(goal.y - pos.y)
    
    var turns = 0
    let globalDirection = Direction(
      (goal.x - pos.x).signum(), (goal.y - pos.y).signum())
    if globalDirection.dx != 0 && globalDirection.dy != 0 {
      turns += 1
      turns +=
        (direction == Direction(0, globalDirection.dy)
          || direction == Direction(globalDirection.dx, 0)) ? 0 : 1
    } else {
      // Opposit direction?
      turns += (direction == globalDirection * -1) ? 2 : 0
      // 90 degree off?
      turns += abs(direction.dx) == abs(globalDirection.dy) ? 1 : 0
    }

    return distance + turns * 1000 + cost
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

    var closedList = Set<FullState>([])
    var openList = Heap<FullState>([
      FullState(
        pos: maze.startPos, direction: Direction(1, 0), goal: maze.endPos, cost: 0)
    ])

    while let fullState = openList.popMin() {
      if false {
        for y in 0..<maze.map.height {
          for x in 0..<maze.map.width {
            let pos = Position(x, y)
            if pos == fullState.pos {
              switch fullState.direction {
              case Direction(1, 0): print(">", terminator: "")
              case Direction(-1, 0): print("<", terminator: "")
              case Direction(0, -1): print("^", terminator: "")
              case Direction(0, 1): print("v", terminator: "")
              default: print("?", terminator: "")
              }
            } else {
              print(maze.map[pos] ? " " : "#", terminator: "")
            }
          }
          print()
        }
      }

      closedList.insert(fullState)
      if fullState.pos == fullState.goal {
        break
      }

      openList.insert(
        contentsOf: [
          FullState(
            pos: fullState.pos + fullState.direction,
            direction: fullState.direction,

            goal: fullState.goal,
            cost: fullState.cost + 1),
          FullState(
            pos: fullState.pos,
            direction: Direction.allDirections.next(fullState.direction),

            goal: fullState.goal,
            cost: fullState.cost + 1000),
          FullState(
            pos: fullState.pos,
            direction: Direction.allDirections.prev(fullState.direction),

            goal: fullState.goal,
            cost: fullState.cost + 1000),
        ].filter({ newFullState in
          maze.map[newFullState.pos] && !closedList.contains(newFullState)
        }))
    }

    return closedList.first {
      $0.pos == maze.endPos
    }!.cost
  }

  public static func solvePart2(_ input: String) async -> Int {
    let maze: Maze = parseMaze(input)

    var closedList = Set<FullState>([])
    var openList = Heap<FullState>([
      FullState(
        pos: maze.startPos, direction: Direction(1, 0), goal: maze.endPos, cost: 0)
    ])

    while let fullState = openList.popMin() {
      if false {
        for y in 0..<maze.map.height {
          for x in 0..<maze.map.width {
            let pos = Position(x, y)
            if pos == fullState.pos {
              switch fullState.direction {
              case Direction(1, 0): print(">", terminator: "")
              case Direction(-1, 0): print("<", terminator: "")
              case Direction(0, -1): print("^", terminator: "")
              case Direction(0, 1): print("v", terminator: "")
              default: print("?", terminator: "")
              }
            } else {
              print(maze.map[pos] ? " " : "#", terminator: "")
            }
          }
          print()
        }
      }

      closedList.insert(fullState)
      if fullState.pos == fullState.goal {
        break
      }

      openList.insert(
        contentsOf: getNextStates(fullState).filter({ newFullState in
          maze.map[newFullState.pos] && !closedList.contains(newFullState)
        }))
    }

    let endState = closedList.first { $0.pos == maze.endPos }!
    let startState = FullState(
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

func getNextStates(_ fullState: FullState) -> [FullState] {
  [
    FullState(
      pos: fullState.pos + fullState.direction,
      direction: fullState.direction,

      goal: fullState.goal,
      cost: fullState.cost + 1),
    FullState(
      pos: fullState.pos,
      direction: Direction.allDirections.next(fullState.direction),

      goal: fullState.goal,
      cost: fullState.cost + 1000),
    FullState(
      pos: fullState.pos,
      direction: Direction.allDirections.prev(fullState.direction),

      goal: fullState.goal,
      cost: fullState.cost + 1000),
  ]
}

func getPrevStates(_ fullState: FullState) -> [FullState] {
  [
    FullState(
      pos: fullState.pos - fullState.direction,
      direction: fullState.direction,

      goal: fullState.goal,
      cost: fullState.cost - 1),
    FullState(
      pos: fullState.pos,
      direction: Direction.allDirections.next(fullState.direction),

      goal: fullState.goal,
      cost: fullState.cost - 1000),
    FullState(
      pos: fullState.pos,
      direction: Direction.allDirections.prev(fullState.direction),

      goal: fullState.goal,
      cost: fullState.cost - 1000),
  ]
}
