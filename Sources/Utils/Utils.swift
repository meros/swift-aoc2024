import Foundation

public protocol Day {
  static func solvePart1(_ input: String) async -> Int
  static func solvePart2(_ input: String) async -> Int
  static var onlySolveExamples: Bool { get }
  static var facitPart1: Int { get }
  static var facitPart2: Int { get }
}

extension Day {
  public static var onlySolveExamples: Bool {
    return false
  }
}

public func getInput(_ day: Int, _ session: String) async -> String? {
  do {
    let cacheURL = URL(fileURLWithPath: ".cache/day\(day).txt")
    if let cachedInput = try? String(contentsOf: cacheURL, encoding: .utf8) {
      return cachedInput
    }

    var request = URLRequest(url: URL(string: "https://adventofcode.com/2024/day/\(day)/input")!)
    request.setValue("session=\(session)", forHTTPHeaderField: "Cookie")
    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }

    let input = String(data: data, encoding: .utf8)!

    try FileManager.default.createDirectory(atPath: ".cache", withIntermediateDirectories: true)
    try input.write(to: cacheURL, atomically: true, encoding: .utf8)

    return input
  } catch {
    print("Failed to get input for day \(day): \(error)")
    return nil
  }
}

public func getExampleInput(_ day: Int) -> String? {
  let fileURL = URL(fileURLWithPath: ".cache/day\(day).example.txt")
  // Read file into a string if exists, otherwise create empty template file
  if let exampleInput = try? String(contentsOf: fileURL, encoding: .utf8), !exampleInput.isEmpty {
    return exampleInput
  } else {
    let template = ""
    try? template.write(to: fileURL, atomically: true, encoding: .utf8)
    return nil
  }
}
extension Array where Element: Collection, Element.Index == Int {
  public func transposed() -> [[Element.Element]] {
    guard let firstRow = self.first else {
      return []
    }

    return firstRow.indices.map { index in
      self.map { $0[index] }
    }
  }
}

public struct Position: Hashable {
  public let x: Int
  public let y: Int

  public init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }

  public static func - (lhs: Position, rhs: Position) -> Direction {
    return Direction(lhs.x - rhs.x, lhs.y - rhs.y)
  }

  public static func + (lhs: Position, rhs: Position) -> Position {
    return Position(lhs.x + rhs.x, lhs.y + rhs.y)
  }

  public static func * (lhs: Position, rhs: Int) -> Position {
    return Position(lhs.x * rhs, lhs.y * rhs)
  }

  public static func + (lhs: Position, rhs: Direction) -> Position {
    return Position(lhs.x + rhs.dx, lhs.y + rhs.dy)
  }

  public static func - (lhs: Position, rhs: Direction) -> Position {
    return Position(lhs.x - rhs.dx, lhs.y - rhs.dy)
  }
}

extension String {
  public func parseGrid() -> [[Substring.Element]] {
    self.split(separator: "\n").map { line in
      line.map { $0 }
    }
  }

  public func parseLines<T>(_ transform: (Substring) -> T) -> [T] {
    self.split(separator: "\n").map(transform)
  }

  public func parseNumberGrid() -> [[Int]] {
    self.split(separator: "\n").map { line in
      line.split(separator: " ").compactMap { Int($0) }
    }
  }
}

public struct Grid<T>: Sequence {
  public struct Iterator: IteratorProtocol {
    private let grid: Grid
    private var currentX = 0
    private var currentY = 0

    init(grid: Grid) {
      self.grid = grid
    }

    public mutating func next() -> (Position, T)? {
      guard currentY < grid.height else { return nil }
      let position = Position(currentX, currentY)
      let value = grid[position]

      currentX += 1
      if currentX == grid.width {
        currentX = 0
        currentY += 1
      }

      return (position, value)
    }
  }

  public func makeIterator() -> Iterator {
    return Iterator(grid: self)
  }

  public var values: [[T]]
  public let width: Int
  public let height: Int

  public init(_ values: [[T]]) {
    self.values = values
    self.width = values[0].count
    self.height = values.count
  }

  public func inBounds(_ position: Position) -> Bool {
    position.x >= 0 && position.x < width && position.y >= 0 && position.y < height
  }

  public subscript(position: Position) -> T {
    get {
      values[position.y][position.x]
    }
    set {
      values[position.y][position.x] = newValue
    }
  }

  public func transposed() -> Grid<T> {
    Grid(values.transposed())
  }
}

public struct Direction: Hashable {
  public static let up = Direction(0, -1)
  public static let down = Direction(0, 1)
  public static let left = Direction(-1, 0)
  public static let right = Direction(1, 0)

  public let dx: Int
  public let dy: Int
  public init(_ dx: Int, _ dy: Int) {
    self.dx = dx
    self.dy = dy
  }

  public static let allDirections: [Direction] = [.up, .right, .down, .left]

  public func rotateRight() -> Direction {
    Direction(-dy, dx)
  }

  public func rotateLeft() -> Direction {
    Direction(dy, -dx)
  }

  public static func * (lhs: Direction, rhs: Int) -> Direction {
    return Direction(lhs.dx * rhs, lhs.dy * rhs)
  }

}

extension Collection where Element: Collection {
  public var dimensions: (width: Int, height: Int) {
    guard let firstRow = self.first else { return (0, 0) }
    return (firstRow.count, self.count)
  }
}

extension Collection {
  public func count(where predicate: (Element) -> Bool) -> Int {
    self.filter(predicate).count
  }
}
