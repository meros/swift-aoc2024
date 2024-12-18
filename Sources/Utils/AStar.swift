import Collections

public protocol Graph {
  associatedtype State: Hashable
  associatedtype Cost: Comparable & Numeric

  func neighbors(of state: State) -> [(State, Cost)]
  func heuristic(from state: State, to goal: State) -> Cost
}

private struct PathNode<State, Cost: Comparable>: Comparable {
  let cost: Cost
  let state: State

  static func < (lhs: PathNode<State, Cost>, rhs: PathNode<State, Cost>) -> Bool {
    lhs.cost < rhs.cost
  }

  static func == (lhs: PathNode<State, Cost>, rhs: PathNode<State, Cost>) -> Bool {
    lhs.cost == rhs.cost
  }
}
extension Graph {
  public func shortestPath(
    from start: State,
    to goal: State
  ) -> (cost: Cost?, visited: Set<State>) {
    typealias State = Self.State
    typealias Cost = Self.Cost

    var frontier = Heap<PathNode<State, Cost>>()
    var visited = Set<State>()

    frontier.insert(PathNode(cost: 0, state: start))

    while let current = frontier.popMin() {
      if visited.contains(current.state) {
        continue
      }
      visited.insert(current.state)

      if current.state == goal {
        return (current.cost, visited)
      }

      for (neighbor, edgeCost) in neighbors(of: current.state) {
        let priority = current.cost + edgeCost + heuristic(from: neighbor, to: goal)
        frontier.insert(PathNode(cost: priority, state: neighbor))
      }
    }

    return (nil, visited)
  }
}
