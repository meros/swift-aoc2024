import Foundation
import Utils

let debugPrint = false

struct Warehouse {
  var layout: Grid<Character>
  var robotMoves: [Direction]
  var robotPos: Position
}

struct BoxMovement {
  let from: Position
  let to: Position
}

private func parseWarehouse(_ input: String, useWideLayout: Bool = false) -> Warehouse {
  let parts = input.split(separator: "\n\n")
  let layout = parts[0].flatMap {
    switch $0 {
    case ".": ".."
    case "#": "##"
    case "@": "@."
    case "O": "[]"
    case "\n": "\n"
    default: "XX"
    }
  }

  let grid = Grid((useWideLayout ? String(layout) : String(parts[0])).parseGrid())
  let moves = parts[1].compactMap { char -> Direction? in
    switch char {
    case "^": .init(0, -1)
    case "v": .init(0, 1)
    case "<": .init(-1, 0)
    case ">": .init(1, 0)
    default: nil
    }
  }

  return Warehouse(layout: grid, robotMoves: moves, robotPos: grid.first { $0.1 == "@" }!.0)
}

private func simulateRobot(_ warehouse: inout Warehouse) {
  while !warehouse.robotMoves.isEmpty {
    let move = warehouse.robotMoves.removeFirst()

    if debugPrint {
      print(move)
      for y in 0..<warehouse.layout.height {
        for x in 0..<warehouse.layout.width {
          print(warehouse.layout[Position(x, y)], terminator: "")
        }
        print()
      }
    }

    alreadyProcessedMoves.removeAll(keepingCapacity: true)
    let movements = moveBox(&warehouse, warehouse.robotPos, move)

    guard let movements = movements else { continue }

    for movement in movements {
      warehouse.layout[movement.to] = warehouse.layout[movement.from]
      warehouse.layout[movement.from] = "."
    }

    if movements.count > 0 {
      warehouse.robotPos = warehouse.robotPos + move
    }
  }
}

var alreadyProcessedMoves = Set<Position>()
private func moveBox(
  _ warehouse: inout Warehouse,
  _ from: Position,
  _ direction: Direction
)
  -> [BoxMovement]?
{
  if alreadyProcessedMoves.contains(from) {
    return []
  }

  alreadyProcessedMoves.insert(from)

  let to = from + direction
  let movement = BoxMovement(from: from, to: to)

  if !warehouse.layout.inBounds(to) || warehouse.layout[to] == "#" {
    return nil
  }

  if warehouse.layout[to] == "." {
    return [movement]
  }

  var boxPositions = [to]
  if direction.dy != 0 {
    if warehouse.layout[to] == "[" {
      boxPositions.append(to + Direction(1, 0))
    }
    if warehouse.layout[to] == "]" {
      boxPositions.append(to + Direction(-1, 0))
    }
  }

  let movements = boxPositions.compactMap {
    moveBox(&warehouse, $0, direction)
  }
  guard movements.count == boxPositions.count else { return nil }

  var result: [BoxMovement] = movements.reduce(into: []) { $0.append(contentsOf: $1) }
  result.append(movement)
  return result
}

public struct Solution: Day {
  public static var facitPart1: Int = 1_465_152

  public static var facitPart2: Int = 1_511_259

  public static var onlySolveExamples: Bool { false }
  public static func solvePart1(_ input: String) async -> Int {
    var warehouse = parseWarehouse(input)
    simulateRobot(&warehouse)
    return calculateGPSScore(warehouse)
  }

  public static func solvePart2(_ input: String) async -> Int {
    var warehouse = parseWarehouse(input, useWideLayout: true)
    simulateRobot(&warehouse)
    return calculateGPSScore(warehouse)
  }
}

private func calculateGPSScore(_ warehouse: Warehouse) -> Int {
  warehouse.layout.map { pos, c in
    if c == "O" || c == "[" {
      pos.x + pos.y * 100
    } else {
      0
    }
  }.reduce(0, +)
}
