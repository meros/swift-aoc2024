import Foundation
import Utils

struct CacheKey: Hashable {
  let from: Character
  let to: Character
  let level: Int
  let numericLevel: Int?
}

var costCache = [CacheKey: Int]()

func cost(_ from: Character, _ to: Character, level: Int, numericLevel: Int? = nil) -> Int? {
  let key = CacheKey(from: from, to: to, level: level, numericLevel: numericLevel)
  
  if let cachedCost = costCache[key] {
    return cachedCost
  }

  // Human operator
  switch level {
  case 0:
    return 1
  default:
    let solver = level == numericLevel ? RobotGraph(
      charToPosDirection, posToCharDirection, charToPosNumeric, posToCharNumeric,
      level: level - 1
    ) : RobotGraph(
      charToPosDirection, posToCharDirection, charToPosDirection, posToCharDirection,
      level: level - 1
    )
    
    guard
      let result = solver.shortestPath(
        from: RobotState(robotPointsAt: from, operatorPointsAt: "A", enteredSequence: ""),
        to: RobotState(robotPointsAt: to, operatorPointsAt: "A", enteredSequence: "\(to)")
      )
    else {
      return nil
    }

    let chars = result.getPath().compactMap { $0.1 }

    let totalCost = zip("A" + chars.dropLast(), chars).map { (from: $0, to: $1) }.compactMap {
      cost($0.from, $0.to, level: level - 1, numericLevel: numericLevel)
    }.reduce(0, +)
    
    costCache[key] = totalCost
    return totalCost
  }
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
    if let cost = cost(state.operatorPointsAt, "A", level: level) {
      each(
        RobotState(
          robotPointsAt: state.robotPointsAt,
          operatorPointsAt: "A",
          enteredSequence: state.enteredSequence + "\(state.robotPointsAt)"
        ), "A", cost)
    }

    let directions: [(Direction, Character)] = [
      (.right, ">"),
      (.left, "<"),
      (.down, "v"),
      (.up, "^"),
    ]

    for (direction, char) in directions {
      if let robotToPos = self.robotPosToChar(robotPos + direction),
        let cost = cost(state.operatorPointsAt, char, level: level)
      {
        each(
          RobotState(
            robotPointsAt: robotToPos,
            operatorPointsAt: char,
            enteredSequence: state.enteredSequence
          ), char, cost)
      }
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

  public static var facitPart1: Int = 163920

  public static func solvePart1(_ input: String) async -> Int {
    let codes = input.components(separatedBy: .newlines)

    var sum = 0

    for code in codes {
      guard let numeric = Int(code.filter { $0.isNumber }) else {
        print("No numeric part found in code: \(code)")
        continue
      }

      var codeCost = 0

      for index in code.indices {
        let robotFrom =
          index > code.startIndex
          ? code[code.index(before: index)] : "A"
        let robotTo = code[index]

        guard let partialCost = cost(robotFrom, robotTo, level: 3, numericLevel: 3) else {
          continue
        }

        codeCost += partialCost
      }

      print("Partial, code cost: ", codeCost, numeric)

      sum += codeCost * numeric
    }

    return sum
  }

  public static func solvePart2(_ input: String) async -> Int {
     let codes = input.components(separatedBy: .newlines)

    var sum = 0

    for code in codes {
      guard let numeric = Int(code.filter { $0.isNumber }) else {
        print("No numeric part found in code: \(code)")
        continue
      }

      var codeCost = 0

      for index in code.indices {
        let robotFrom =
          index > code.startIndex
          ? code[code.index(before: index)] : "A"
        let robotTo = code[index]

        guard let partialCost = cost(robotFrom, robotTo, level: 26, numericLevel: 26) else {
          continue
        }

        codeCost += partialCost
      }

      print("Partial, code cost: ", codeCost, numeric)

      sum += codeCost * numeric
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

func charToPosNumeric(_ char: Character) -> Position? {
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
