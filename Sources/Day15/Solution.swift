import Collections
import Foundation
import Utils

let debugPrint = false

struct Warehouse {
  var layout: Grid<Character>
  var robotMoves: [Direction]
  var robotPos: Position
}

private func parseWarehouse(_ input: String, useWideLayout: Bool = false) -> Warehouse {
  let parts = input.split(separator: "\n\n")
  let layouString = String(parts[0])
  let wideLayoutString = layouString.flatMap {
    switch $0 {
    case ".": ".."
    case "#": "##"
    case "@": "@."
    case "O": "[]"
    case "\n": "\n"
    default: "XX"
    }
  }

  let layout = Grid((useWideLayout ? String(wideLayoutString) : layouString).parseGrid())
  let robotMoves = parts[1].compactMap { char -> Direction? in
    switch char {
    case "^": .init(0, -1)
    case "v": .init(0, 1)
    case "<": .init(-1, 0)
    case ">": .init(1, 0)
    default: nil
    }
  }

  let robotPos = layout.first { $0.1 == "@" }!.0

  return Warehouse(layout: layout, robotMoves: robotMoves, robotPos: robotPos)
}

private func simulateRobot(_ warehouse: inout Warehouse) {
  for move in warehouse.robotMoves {

    if debugPrint {
      print(move)
      for y in 0..<warehouse.layout.height {
        for x in 0..<warehouse.layout.width {
          print(warehouse.layout[Position(x, y)], terminator: "")
        }
        print()
      }
    }

    for movedPos in moveBox(&warehouse, warehouse.robotPos, move) ?? [] {
      warehouse.layout[movedPos + move] = warehouse.layout[movedPos]
      warehouse.layout[movedPos] = "."

      if warehouse.robotPos == movedPos {
        warehouse.robotPos = movedPos + move
      }
    }
  }
}

private func moveBox(
  _ warehouse: inout Warehouse,
  _ from: Position,
  _ direction: Direction
)
  -> OrderedSet<Position>?
{
  let to = from + direction

  if !warehouse.layout.inBounds(to) || warehouse.layout[to] == "#" {
    return nil
  }

  if warehouse.layout[to] == "." {
    return [from]
  }

  var boxPositions = OrderedSet([to])

  if direction.dy != 0 {
    if warehouse.layout[to] == "[" {
      boxPositions.append(to + Direction(1, 0))
    }
    if warehouse.layout[to] == "]" {
      boxPositions.append(to + Direction(-1, 0))
    }
  }

  let movements =
    boxPositions.compactMap {
      moveBox(&warehouse, $0, direction)
    } + [OrderedSet([from])]

  guard movements.count == boxPositions.count + 1 else { return nil }
  return movements.reduce(into: OrderedSet([])) { $0.formUnion($1) }
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
    c == "O" || c == "["
      ? pos.x + pos.y * 100
      : 0
  }.reduce(0, +)
}
