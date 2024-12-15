import Collections
import Foundation
import Utils

struct Warehouse: Hashable {
  var layout: Grid<Character>
  var robotMoves: [Direction]
  var robotPos: Position
}

struct BoxMovement: Hashable {
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

  var robotPos: Position? = nil
  grid.forEach { pos, c in
    if c == "@" {
      robotPos = pos
    }
  }

  return Warehouse(layout: grid, robotMoves: moves, robotPos: robotPos!)
}

private func simulateRobot(_ warehouse: inout Warehouse) {
  while !warehouse.robotMoves.isEmpty {
    let move = warehouse.robotMoves.removeFirst()
    let movements = moveBox(&warehouse, warehouse.robotPos, move)

    for movement in movements {
      warehouse.layout[movement.to] = warehouse.layout[movement.from]
      warehouse.layout[movement.from] = "."
    }
  }
}

private func moveBox(_ warehouse: inout Warehouse, _ from: Position, _ direction: Direction)
  -> OrderedSet<BoxMovement>
{
  let to = from + direction
  let movement = BoxMovement(from: from, to: to)

  if !warehouse.layout.inBounds(to) || warehouse.layout[to] == "#" {
    return []
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

  let movements = boxPositions.map { moveBox(&warehouse, $0, direction) }
  guard movements.allSatisfy({ !$0.isEmpty }) else { return [] }

  var result = movements.reduce(into: OrderedSet<BoxMovement>()) { $0.append(contentsOf: $1) }
  result.append(movement)
  return result
}

public struct Solution: Day {
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
  var score = 0
  warehouse.layout.forEach { pos, c in
    if c == "O" || c == "[" {
      score += pos.x + pos.y * 100
    }
  }
  return score
}
