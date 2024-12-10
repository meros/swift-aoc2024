import Foundation
import Utils

func parsedInput(_ input: String) -> Grid<Int> {
  Grid(
    input.parseGrid().map {
      $0.map {
        Int(String($0))!
      }
    })
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let grid = parsedInput(input)

    var valuesToCheck: [(at: Position, from: Position)] = []
    for y in 0..<grid.height {
      for x in 0..<grid.width {
        if grid.values[y][x] == 0 {
          valuesToCheck.append((at: Position(x, y), from: Position(x, y)))
        }
      }
    }

    var nines: [Position: Set<Position>] = [:]

    while valuesToCheck.count > 0 {
      let value = valuesToCheck.removeFirst()
      print("Checking \(value.at) \(grid[value.at])")
      if grid[value.at] == 9 {
        let oldValue = nines[value.from]
        if oldValue == nil {
          nines[value.from] = [value.at]
        } else {
          nines[value.from] = oldValue!.union([value.at])
        }
      }

      let newValues = Direction.allDirections.compactMap {
        direction -> (at: Position, from: Position)? in
        let newPosition = value.0 + direction
        if !grid.inBounds(newPosition) {
          return nil
        }

        if grid[newPosition] != grid[value.at] + 1 {
          return nil
        }

        return (at: newPosition, from: value.from)
      }
      valuesToCheck.forEach { (position, from) in
      }

      valuesToCheck.append(contentsOf: newValues)
    }

    return nines.values.map { $0.count }.reduce(0, +)
  }

  public static func solvePart2(_ input: String) async -> Int {
     let grid = parsedInput(input)

    var valuesToCheck: [(at: Position, from: Position)] = []
    for y in 0..<grid.height {
      for x in 0..<grid.width {
        if grid.values[y][x] == 0 {
          valuesToCheck.append((at: Position(x, y), from: Position(x, y)))
        }
      }
    }

    var nines: [Position: Int] = [:]

    while valuesToCheck.count > 0 {
      let value = valuesToCheck.removeFirst()
      print("Checking \(value.at) \(grid[value.at])")
      if grid[value.at] == 9 {
        let oldValue = nines[value.from]
        if oldValue == nil {
          nines[value.from] = 1
        } else {
          nines[value.from] = oldValue! + 1
        }
      }

      let newValues = Direction.allDirections.compactMap {
        direction -> (at: Position, from: Position)? in
        let newPosition = value.0 + direction
        if !grid.inBounds(newPosition) {
          return nil
        }

        if grid[newPosition] != grid[value.at] + 1 {
          return nil
        }

        return (at: newPosition, from: value.from)
      }
      valuesToCheck.forEach { (position, from) in
      }

      valuesToCheck.append(contentsOf: newValues)
    }

    return nines.values.reduce(0, +)
  }
}
