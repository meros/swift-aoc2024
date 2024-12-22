import Foundation
import Utils

/** Final keypad
Robot A:
+---+---+---+
| 7 | 8 | 9 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
    | 0 | A |
    +---+---+
*/

/**
Robot B:
    +---+---+
    | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+

Robot C:
    +---+---+
    | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+

Human operator:
Robot B:
    +---+---+
    | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+
*/

func cost(_ from: Character, _ to: Character, level: Int) -> Int {
  // Human operator
  if level == 0 {
    return 1
  }

  let robotGraph = RobotGraph(
    charToPosDirection, posToCharDirection, charToPosDirection, posToCharDirection, level: level - 1
  )

  let solution = robotGraph.shortestPath(
    from: RobotState(robotPointsAt: from, operatorPointsAt: "A", enteredSequence: ""),
    to: RobotState(robotPointsAt: to, operatorPointsAt: "A", enteredSequence: "\(to)")
  )

  return solution.cost!
}

struct RobotState: Hashable {
  let robotPointsAt: Character
  let operatorPointsAt: Character
  let enteredSequence: String
}

class RobotGraph: Graph {
  typealias State = RobotState
  typealias Cost = Int

  let operatorCharToPos: (_ char: Character) -> Position?
  let operatorPosToChar: (_ pos: Position) -> Character?
  let robotCharToPos: (_ char: Character) -> Position?
  let robotPosToChar: (_ pos: Position) -> Character?

  var level: Int

  init(
    _ operatorCharToPos: @escaping (_ char: Character) -> Position?,
    _ operatorPosToChar: @escaping (_ pos: Position) -> Character?,
    _ robotCharToPos: @escaping (_ char: Character) -> Position?,
    _ robotPosToChar: @escaping (_ pos: Position) -> Character?,
    level: Int = 0
  ) {
    self.operatorCharToPos = operatorCharToPos
    self.operatorPosToChar = operatorPosToChar
    self.robotCharToPos = robotCharToPos
    self.robotPosToChar = robotPosToChar
    self.level = level
  }

  func neighbors(of state: State, each: (State, Character, Int) -> Void) {
    guard let robotPos = self.robotCharToPos(state.robotPointsAt) else {
      print("No robot position, robot points at: \(state.robotPointsAt)")
      return
    }

    // Operator press 'A'
    each(
      RobotState(
        robotPointsAt: state.robotPointsAt,
        operatorPointsAt: "A",
        enteredSequence: state.enteredSequence + "\(state.robotPointsAt)"
      ), "A", cost(state.operatorPointsAt, "A", level: level))

    // Operator press '>'
    if let robotToPos = self.robotPosToChar(robotPos + Direction.right) {
      each(
        RobotState(
          robotPointsAt: robotToPos,
          operatorPointsAt: ">",
          enteredSequence: state.enteredSequence
        ), ">", cost(state.operatorPointsAt, ">", level: level))
    }

    // Operator press '<'
    if let robotToPos = self.robotPosToChar(robotPos + Direction.left) {
      each(
        RobotState(
          robotPointsAt: robotToPos,
          operatorPointsAt: "<",
          enteredSequence: state.enteredSequence
        ), "<", cost(state.operatorPointsAt, "<", level: level))
    }

    // Operator press 'v'
    if let robotToPos = self.robotPosToChar(robotPos + Direction.down) {
      each(
        RobotState(
          robotPointsAt: robotToPos,
          operatorPointsAt: "v",
          enteredSequence: state.enteredSequence
        ), "v", cost(state.operatorPointsAt, "v", level: level))
    }

    // Operator press '^'
    if let robotToPos = self.robotPosToChar(robotPos + Direction.up) {
      each(
        RobotState(
          robotPointsAt: robotToPos,
          operatorPointsAt: "^",
          enteredSequence: state.enteredSequence
        ), "^", cost(state.operatorPointsAt, "^", level: level))
    }
  }

  func heuristic(from state: State, to target: State) -> Int? {
    if state.enteredSequence.count > target.enteredSequence.count {
      return nil
    }

    if !target.enteredSequence.hasPrefix(state.enteredSequence) {
      return nil
    }

    if state.enteredSequence == target.enteredSequence {
      return 0
    }

    return target.enteredSequence.count - state.enteredSequence.count
  }
}

public class Solution: Day {
  public static var onlySolveExamples: Bool = false

  public static func solvePart1(_ input: String) async -> Int {
    let codes = input.components(separatedBy: .newlines)

    let robotGraph = RobotGraph(
      charToPosDirection, posToCharDirection, charToNumeric, posToCharNumeric)

    let robot2Graph = RobotGraph(
      charToPosDirection, posToCharDirection, charToPosDirection, posToCharDirection)

    let levels = [
      (robotGraph, 2),
      (robot2Graph, 1),
      (robot2Graph, 0),
    ]

    var sum = 0

    for code in codes {
      let numericPart = Int(code.filter { $0.isNumber })
      guard let numeric = numericPart else {
        print("No numeric part found in code: \(code)")
        continue
      }

      print("Solving for code: \(code), numeric: \(numeric)")

      var desiredSequence = code

      for (solver, level) in levels {
        let from = RobotState(robotPointsAt: "A", operatorPointsAt: "A", enteredSequence: "")
        let to: RobotState = RobotState(
          robotPointsAt: "A", operatorPointsAt: "A", enteredSequence: desiredSequence)

        solver.level = level

        let result = solver.shortestPath(
          from: from, to: to)

        let partialSolution = solver.getPath(
          result.visited, from, to
        ).compactMap {
          if let char = $1 {
            return "\(char)"
          }

          return nil
        }.joined()

        print("Partial solution: \(partialSolution)")
        desiredSequence = partialSolution
      }

      let partialSum = desiredSequence.count * numeric
      print("Partial sum: \(partialSum), count: \(desiredSequence.count), numeric: \(numeric)")
      sum += partialSum
    }

    return sum
  }
}

func posToCharNumeric(_ pos: Position) -> Character? {
  /*
  +---+---+---+
| 7 | 8 | 9 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
    | 0 | A |
    +---+---+
    */
  switch pos {
  case Position(0, 0): return "7"
  case Position(1, 0): return "8"
  case Position(2, 0): return "9"
  case Position(0, 1): return "4"
  case Position(1, 1): return "5"
  case Position(2, 1): return "6"
  case Position(0, 2): return "1"
  case Position(1, 2): return "2"
  case Position(2, 2): return "3"
  case Position(2, 3): return "A"
  case Position(1, 3): return "0"
  default:
    return nil
  }
}

func charToNumeric(_ char: Character) -> Position? {
  /*
  +---+---+---+
| 7 | 8 | 9 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
    | 0 | A |
    +---+---+
    */
  switch char {
  case "7": return Position(0, 0)
  case "8": return Position(1, 0)
  case "9": return Position(2, 0)
  case "4": return Position(0, 1)
  case "5": return Position(1, 1)
  case "6": return Position(2, 1)
  case "1": return Position(0, 2)
  case "2": return Position(1, 2)
  case "3": return Position(2, 2)
  case "A": return Position(2, 3)
  case "0": return Position(1, 3)
  default:
    return nil
  }
}

func charToPosDirection(_ char: Character) -> Position? {
  /*
    +---+---+
    | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+
*/

  switch char {
  case "<": return Position(0, 1)
  case "^": return Position(1, 0)
  case ">": return Position(2, 1)
  case "v": return Position(1, 1)
  case "A": return Position(2, 0)
  default:
    return nil
  }
}

func posToCharDirection(_ pos: Position) -> Character? {
  /*
    +---+---+
    | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+
*/

  switch pos {
  case Position(0, 1): return "<"
  case Position(1, 0): return "^"
  case Position(2, 1): return ">"
  case Position(1, 1): return "v"
  case Position(2, 0): return "A"
  default:
    return nil
  }
}
