public protocol Graph {
  associatedtype State: Hashable
  associatedtype Cost: Comparable & Numeric

  func neighbors(of state: State, each: (_ neighbor: State, _ edgeCost: Cost) -> Void)
  func heuristic(from state: State, to goal: State) -> Cost
}

public struct PathNode<State, Cost: Comparable>: Comparable {
  @usableFromInline
  let gScore: Cost  // Actual cost to reach this node
  @usableFromInline
  let fScore: Cost  // Priority score (g + h) for heap ordering
  @usableFromInline
  let state: State

  @usableFromInline
  init(gScore: Cost, fScore: Cost, state: State) {
    self.gScore = gScore
    self.fScore = fScore
    self.state = state
  }

  @inlinable
  public static func < (lhs: PathNode<State, Cost>, rhs: PathNode<State, Cost>) -> Bool {
    lhs.fScore < rhs.fScore
  }

  @inlinable
  public static func == (lhs: PathNode<State, Cost>, rhs: PathNode<State, Cost>) -> Bool {
    lhs.fScore == rhs.fScore
  }
}

extension Graph {
  @inlinable
  public func shortestPath(
    from start: State,
    to goal: State
  ) -> (cost: Cost?, visited: Set<State>) {
    var frontier = PriorityQueue<PathNode<State, Cost>>()
    var visited = Set<State>()

    let startNode = PathNode(
      gScore: 0,
      fScore: heuristic(from: start, to: goal),
      state: start
    )
    frontier.push(startNode)

    while let current = frontier.popMin() {
      if current.state == goal {
        return (current.gScore, visited)
      }

      if visited.contains(current.state) {
        continue
      }
      visited.insert(current.state)

      neighbors(of: current.state) {
        neighbor, edgeCost in
        let newGScore = current.gScore + edgeCost
        let newFScore = newGScore + heuristic(from: neighbor, to: goal)

        frontier.push(
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

public struct PriorityQueue<Element: Comparable> {
  @usableFromInline
  var elements: [Element] = []

  /// Check if the queue is empty.
  @inlinable
  var isEmpty: Bool {
    elements.isEmpty
  }

  /// Insert a new element (constant time).
  @inlinable
  mutating func push(_ element: Element) {
    elements.append(element)
  }

  /// Remove and return the smallest element (linear time).
  @inlinable
  mutating func popMin() -> Element? {
    guard !elements.isEmpty else { return nil }
    var minIndex = 0
    for i in 1..<elements.count {
      if elements[i] < elements[minIndex] {
        minIndex = i
      }
    }
    return elements.remove(at: minIndex)
  }

  /// Peek at the smallest element without removing (linear time).
  @inlinable
  func peekMin() -> Element? {
    elements.min()
  }

  @inlinable
  init() {}
}
