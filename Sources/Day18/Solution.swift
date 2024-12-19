import Collections
import Foundation
import Utils

private let memoryWidth = 71
private let memoryHeight = 71

private struct MemoryGraph: Graph {
  typealias State = Position
  typealias Cost = Int

  let corruptedBytes: Set<Position>

  func neighbors(of state: Position) -> [(Position, Int)] {
    Direction.allDirections
      .map { state + $0 }
      .filter { pos in
        pos.x >= 0 && pos.x < memoryWidth && pos.y >= 0 && pos.y < memoryHeight
          && !corruptedBytes.contains(pos)
      }
      .map { ($0, 1) }
  }

  func heuristic(from state: Position, to goal: Position) -> Int {
    abs(goal.x - state.x) + abs(goal.y - state.y)
  }
}

public class Solution: Day {
  public static var onlySolveExamples: Bool { false }
  public static var facitPart1: Int = 246
  public static var facitPart2String: String = "22,50"

  public static func solvePart1(_ input: String) async -> Int {
    let corruptedBytes = Set(parseCorruptedBytes(input)[0..<1024])
    let graph = MemoryGraph(corruptedBytes: corruptedBytes)
    let start = Position(0, 0)
    let goal = Position(memoryWidth - 1, memoryHeight - 1)

    return graph.shortestPath(from: start, to: goal).cost ?? 0
  }

  public static func solvePart2String(_ input: String) async -> String {
    let allCorruptedPositions = parseCorruptedBytes(input)
    var upperIndex = allCorruptedPositions.count - 1
    var lowerIndex = 1023
    var firstBlockingIndex = upperIndex

    while lowerIndex < upperIndex {
      let index = (upperIndex + lowerIndex) / 2
      let corruptedBytes = Set(allCorruptedPositions[0...index])
      let graph = MemoryGraph(corruptedBytes: corruptedBytes)
      let start = Position(0, 0)
      let goal = Position(memoryWidth - 1, memoryHeight - 1)

      if graph.shortestPath(from: start, to: goal).cost != nil {
        lowerIndex = index + 1
      } else {
        firstBlockingIndex = index
        upperIndex = index
      }
    }

    let firstBlockingByte = allCorruptedPositions[firstBlockingIndex]
    return "\(firstBlockingByte.x),\(firstBlockingByte.y)"
  }
}

private func parseCorruptedBytes(_ input: String) -> [Position] {
  input.matches(of: #/(?<x>[0-9]+),(?<y>[0-9]+)/#).map {
    Position(Int($0.output.x)!, Int($0.output.y)!)
  }
}
