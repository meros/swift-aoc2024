import Collections

public protocol Graph {
  associatedtype State: Hashable
  associatedtype Cost: Comparable & Numeric

  func neighbors(of state: State) -> [(State, Cost)]
  func heuristic(from state: State, to goal: State) -> Cost
}

private struct PathNode<State, Cost: Comparable>: Comparable {
  let gScore: Cost  // Actual cost to reach this node
  let fScore: Cost  // Priority score (g + h) for heap ordering
  let state: State

  static func < (lhs: PathNode<State, Cost>, rhs: PathNode<State, Cost>) -> Bool {
    lhs.fScore < rhs.fScore
  }

  static func == (lhs: PathNode<State, Cost>, rhs: PathNode<State, Cost>) -> Bool {
    lhs.fScore == rhs.fScore
  }
}

extension Graph {
  public func shortestPath(
    from start: State,
    to goal: State
  ) -> (cost: Cost?, visited: Set<State>) {
    var frontier = Heap<PathNode<State, Cost>>()
    var visited = Set<State>()

    let startNode = PathNode(
      gScore: 0,
      fScore: heuristic(from: start, to: goal),
      state: start
    )
    frontier.insert(startNode)

    while let current = frontier.popMin() {
      if current.state == goal {
        return (current.gScore, visited)
      }

      if visited.contains(current.state) {
        continue
      }
      visited.insert(current.state)

      for (neighbor, edgeCost) in neighbors(of: current.state) {
        let newGScore = current.gScore + edgeCost
        let newFScore = newGScore + heuristic(from: neighbor, to: goal)

        frontier.insert(
          PathNode(
            gScore: newGScore,
            fScore: newFScore,
            state: neighbor
          ))
      }
    }

    return (nil, visited)
  }
}
