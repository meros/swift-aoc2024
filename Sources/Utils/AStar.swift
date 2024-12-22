public protocol Graph {
  associatedtype State: Hashable
  associatedtype Edge
  associatedtype Cost: Comparable & Numeric

  func neighbors(of state: State, each: (_ neighbor: State, _ edge: Edge, _ edgeCost: Cost) -> Void)
  func heuristic(from state: State, to goal: State) -> Cost?
}

public struct PathNode<State, Edge, Cost: Comparable>: Comparable {
  @usableFromInline
  let gScore: Cost  // Actual cost to reach this node
  @usableFromInline
  let fScore: Cost  // Priority score (g + h) for heap ordering
  @usableFromInline
  let state: State
  @usableFromInline
  let previous: (edge: Edge, state: State)?

  @usableFromInline
  init(gScore: Cost, fScore: Cost, state: State, previous: (edge: Edge, state: State)? = nil) {
    self.gScore = gScore
    self.fScore = fScore
    self.state = state
    self.previous = previous
  }

  @inlinable
  public static func < (lhs: PathNode<State, Edge, Cost>, rhs: PathNode<State, Edge, Cost>) -> Bool
  {
    lhs.fScore < rhs.fScore
  }

  @inlinable
  public static func == (lhs: PathNode<State, Edge, Cost>, rhs: PathNode<State, Edge, Cost>) -> Bool
  {
    lhs.fScore == rhs.fScore
  }
}

extension Graph {
  @inlinable
  public func shortestPath(
    from start: State,
    to goal: State
  ) -> (cost: Cost?, visited: [State: (edge: Edge, state: State)]) {
    var frontier = PriorityQueue<PathNode<State, Edge, Cost>>()
    var visited: [State: (edge: Edge, state: State)] = [:]

    guard let fStart = heuristic(from: start, to: goal) else {
      return (nil, visited)
    }

    let startNode = PathNode<State, Edge, Cost>(
      gScore: 0,
      fScore: fStart,
      state: start
    )
    frontier.push(startNode)

    while let current = frontier.popMin() {
      if visited.index(forKey: current.state) != nil {
        continue
      }

      visited[current.state] = current.previous

      if current.state == goal {
        return (current.gScore, visited)
      }

      neighbors(of: current.state) {
        neighbor, edge, edgeCost in

        guard let hScore = heuristic(from: neighbor, to: goal) else {
          return
        }

        let newGScore = current.gScore + edgeCost
        let newFScore = newGScore + hScore

        frontier.push(
          PathNode(
            gScore: newGScore,
            fScore: newFScore,
            state: neighbor,
            previous: (edge, current.state)
          ))
      }
    }

    return (nil, visited)
  }

  public func getPath(_ visited: [State: (edge: Edge, state: State)], _ start: State, _ goal: State)
    -> [(State, Edge?)]
  {
    var current: State? = goal
    var backTrack: [(State, Edge?)] = []

    while let pos = current {
      if let (edge, state) = visited[pos] {
        backTrack.append((pos, edge))
        current = state

        if state == start {
          break
        }
      }
    }

    return backTrack.reversed()
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
