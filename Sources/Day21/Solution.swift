import Foundation
import Utils

public class Solution: Day {
  public static var onlySolveExamples: Bool = false

  public static var facitPart1: Int = 163920

  public static var facitPart2: Int = 204_040_805_018_350

  public static func solvePart1(_ input: String) async -> Int {
    let codes = input.components(separatedBy: .newlines)

    return solve(codes, 3)
  }

  public static func solvePart2(_ input: String) async -> Int {
    let codes = input.components(separatedBy: .newlines)

    return solve(codes, 26)
  }
}


// Core types
private struct RobotState: Hashable {
  let position: Character
  let command: Character
  let sequence: String
}

private struct CostKey: Hashable {
  let start: Character
  let end: Character
  let depth: Int
  let keypadDepth: Int?
}

// Layout mapping
private enum Layout {
  static func arrowToPosition(_ arrow: Character) -> Position? {
    switch arrow {
    case "<": return Position(0, 1)
    case "^": return Position(1, 0)
    case ">": return Position(2, 1)
    case "v": return Position(1, 1)
    case "A": return Position(2, 0)
    default: return nil
    }
  }

  static func positionToArrow(_ pos: Position) -> Character? {
    switch pos {
    case Position(0, 1): return "<"
    case Position(1, 0): return "^"
    case Position(2, 1): return ">"
    case Position(1, 1): return "v"
    case Position(2, 0): return "A"
    default: return nil
    }
  }

  static func keypadToPosition(_ key: Character) -> Position? {
    switch key {
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
    default: return nil
    }
  }

  static func positionToKeypad(_ pos: Position) -> Character? {
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
    default: return nil
    }
  }
}

// Navigation
private class RobotNavigator: Graph {
  typealias State = RobotState
  typealias Cost = Int

  private let commandToPosition: (Character) -> Position?
  private let positionToCommand: (Position) -> Character?
  private let robotToPosition: (Character) -> Position?
  private let positionToRobot: (Position) -> Character?
  private let depth: Int

  init(depth: Int, useKeypad: Bool = false) {
    self.depth = depth
    if useKeypad {
      self.commandToPosition = Layout.keypadToPosition
      self.positionToCommand = Layout.positionToKeypad
      self.robotToPosition = Layout.keypadToPosition
      self.positionToRobot = Layout.positionToKeypad
    } else {
      self.commandToPosition = Layout.arrowToPosition
      self.positionToCommand = Layout.positionToArrow
      self.robotToPosition = Layout.arrowToPosition
      self.positionToRobot = Layout.positionToArrow
    }
  }

  func neighbors(of state: State, each: (State, Character, Int) -> Void) {
    guard let robotPos = self.robotToPosition(state.position) else {
      print("No robot position, robot points at: \(state.position)")
      return
    }

    // Operator press 'A'
    if let cost = calculateCost(state.command, "A", depth: depth) {
      each(
        RobotState(
          position: state.position,
          command: "A",
          sequence: state.sequence + "\(state.position)"
        ), "A", cost)
    }

    let directions: [(Direction, Character)] = [
      (.right, ">"),
      (.left, "<"),
      (.down, "v"),
      (.up, "^"),
    ]

    for (direction, char) in directions {
      if let robotToPos = self.positionToRobot(robotPos + direction),
        let cost = calculateCost(state.command, char, depth: depth)
      {
        each(
          RobotState(
            position: robotToPos,
            command: char,
            sequence: state.sequence
          ), char, cost)
      }
    }
  }

  func heuristic(from state: State, to target: State) -> Int? {
    if state.sequence.count > target.sequence.count {
      return nil
    }

    if !target.sequence.hasPrefix(state.sequence) {
      return nil
    }

    if state.sequence == target.sequence {
      return 0
    }

    return target.sequence.count - state.sequence.count
  }
}

// Cost calculation
private var costCache = [CostKey: Int]()

private func calculateCost(_ from: Character, _ to: Character, depth: Int, keypadDepth: Int? = nil)
  -> Int?
{
  let key = CostKey(start: from, end: to, depth: depth, keypadDepth: keypadDepth)

  if let cachedCost = costCache[key] {
    return cachedCost
  }

  // Human operator
  switch depth {
  case 0:
    return 1
  default:
    let solver =
      depth == keypadDepth
      ? RobotNavigator(
        depth: depth - 1, useKeypad: true
      )
      : RobotNavigator(
        depth: depth - 1
      )

    guard
      let result = solver.shortestPath(
        from: RobotState(position: from, command: "A", sequence: ""),
        to: RobotState(position: to, command: "A", sequence: "\(to)")
      )
    else {
      return nil
    }

    let chars = result.getPath().compactMap { $0.1 }

    let totalCost = zip("A" + chars.dropLast(), chars).map { (from: $0, to: $1) }.compactMap {
      calculateCost($0.from, $0.to, depth: depth - 1, keypadDepth: keypadDepth)
    }.reduce(0, +)

    costCache[key] = totalCost
    return totalCost
  }
}


func solve(_ codes: [String], _ levels: Int) -> Int {
  var sum = 0

  for code in codes {
    guard let numeric = Int(code.filter { $0.isNumber }) else {
      continue
    }

    var codeCost = 0

    for index in code.indices {
      let robotFrom =
        index > code.startIndex
        ? code[code.index(before: index)] : "A"
      let robotTo = code[index]

      guard let partialCost = calculateCost(robotFrom, robotTo, depth: levels, keypadDepth: levels)
      else {
        continue
      }

      codeCost += partialCost
    }

    sum += codeCost * numeric
  }

  return sum
}
