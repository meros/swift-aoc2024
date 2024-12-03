import Foundation

public protocol Day {
    static func solvePart1(_ input: String) -> Int
    static func solvePart2(_ input: String) -> Int
}

public func getInput(_ day: Int, _ session: String) async throws -> String {
    let cacheURL = URL(fileURLWithPath: ".cache/day\(day).txt")
    if let cachedInput = try? String(contentsOf: cacheURL, encoding: .utf8) {
        return cachedInput
    }

    var request = URLRequest(url: URL(string: "https://adventofcode.com/2024/day/\(day)/input")!)
    request.setValue("session=\(session)", forHTTPHeaderField: "Cookie")
    let (data, _) = try await URLSession.shared.data(for: request)
    let input = String(data: data, encoding: .utf8)!

    try FileManager.default.createDirectory(atPath: ".cache", withIntermediateDirectories: true)
    try input.write(to: cacheURL, atomically: true, encoding: .utf8)

    return input
}
