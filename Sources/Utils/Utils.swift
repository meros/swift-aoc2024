import Foundation

public protocol Day {
  static func solvePart1(_ input: String) -> Int
  static func solvePart2(_ input: String) -> Int
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

extension [[Int]] {
  public func transposed() -> [[Int]] {
    guard let firstRow = self.first else {
      return []
    }

    return firstRow.indices.map { index in
      self.map { $0[index] }
    }
  }
}

extension [[Character]] {
  public func transposedChar() -> [[Character]] {
    guard let firstRow = self.first else {
      return []
    }

    return firstRow.indices.map { index in
      self.map { $0[index] }
    }
  }
}
