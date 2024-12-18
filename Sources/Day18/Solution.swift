import Collections
import Foundation
import Utils

let memoryWidth = 71
let memoryHeight = 71

struct MemoryState: Comparable {
  static func < (lhs: MemoryState, rhs: MemoryState) -> Bool {
    lhs.heuristicCost < rhs.heuristicCost
  }

  init(position: Position, exit: Position, steps: Int, backtrack: Position? = nil) {
    self.position = position
    self.exit = exit
    self.steps = steps
    self.backtrack = backtrack
    self.heuristicCost = abs(exit.x - position.x) + abs(exit.y - position.y) + steps
  }

  let position: Position
  let exit: Position
  let steps: Int
  let heuristicCost: Int
  let backtrack: Position?
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static var facitPart1: Int = 246

  public static var facitPart2String: String = "22,50"

  public static func solvePart1(_ input: String) async -> Int {
    let corruptedBytes = Array(parseCorruptedBytes(input)[0..<1024])

    return findSafePath(Set(corruptedBytes))!.last!.steps
  }

  public static func solvePart2String(_ input: String) async -> String {
    let allCorruptedPositions = parseCorruptedBytes(input)
    var oldSafePath: Set<Position>?
    for i in 1..<allCorruptedPositions.count {
      let corruptedPositions = Array(allCorruptedPositions[0..<i])
      if let onOldSafePath = oldSafePath?.contains(corruptedPositions.last!),
        !onOldSafePath
      {
        continue
      }

      guard let safePath = findSafePath(Set(corruptedPositions)) else {
        let lastPosition = corruptedPositions.last!
        return "\(lastPosition.x),\(lastPosition.y)"
      }

      oldSafePath = Set(
        safePath.map {
          $0.position
        })
    }
    return ""
  }
}

private func parseCorruptedBytes(_ input: String) -> [Position] {
  input.matches(of: #/(?<x>[0-9]+),(?<y>[0-9]+)/#).map {
    Position(Int($0.output.x)!, Int($0.output.y)!)
  }
}

func findSafePath(_ corruptedBytes: Set<Position>) -> [MemoryState]? {
  let exit = Position(memoryWidth - 1, memoryHeight - 1)

  var visitedPositions: [Position: MemoryState] = [:]
  var pathQueue = Heap([MemoryState(position: Position(0, 0), exit: exit, steps: 0)])

  while let current = pathQueue.popMin() {
    visitedPositions[current.position] = current
    if current.position == exit { break }

    pathQueue.insert(
      contentsOf: Direction.allDirections.map {
        MemoryState(
          position: current.position + $0, exit: exit, steps: current.steps + 1,
          backtrack: current.position)
      }.filter {
        $0.position.x >= 0 && $0.position.x < memoryWidth && $0.position.y >= 0
          && $0.position.y < memoryHeight && visitedPositions.index(forKey: $0.position) == nil
          && !corruptedBytes.contains($0.position)
      }
    )
  }

  guard var state = visitedPositions[exit] else { return nil }
  var result = [state]
  while let backtrack = state.backtrack {
    state = visitedPositions[backtrack]!
    result.insert(state, at: 0)
  }
  return result
}
