import Foundation
import Utils

public class Solution: Day {
  public static var facitPart1: Int = 2578

  public static var facitPart2: Int = 1972

  public static func solvePart1(_ input: String) async -> Int {
    let parsedInput = parseInput(input)

    let word = "XMAS"
    let directions: [(dx: Int, dy: Int)] = [-1, 0, 1].flatMap { x in
      [-1, 0, 1].map { y in (dx: x, dy: y) }
    }.filter { $0 != (dx: 0, dy: 0) }

    var numFound = 0
    for x in 0..<parsedInput.count {
      for y in 0..<parsedInput[x].count {
        for direction: (dx: Int, dy: Int) in directions {
          let lastX = x + (word.count - 1) * direction.dx
          let lastY = y + (word.count - 1) * direction.dy
          if lastX >= 0 && lastX < parsedInput.count && lastY >= 0 && lastY < parsedInput[x].count
            && (0..<word.count).allSatisfy({ i in
              parsedInput[x + i * direction.dx][y + i * direction.dy]
                == word[word.index(word.startIndex, offsetBy: i)]
            })
          {
            numFound += 1
          }
        }
      }
    }
    return numFound
  }

  public static func solvePart2(_ input: String) async -> Int {
    let parsedInput = parseInput(input)

    let directions = [(dx: 1, dy: 1), (dx: 1, dy: -1)]

    var numFound = 0
    for x in 1..<parsedInput.count - 1 {
      for y in 1..<parsedInput[x].count - 1 {
        if parsedInput[x][y] != "A" {
          continue
        }

        if directions.allSatisfy({ direction in
          let a = parsedInput[x + direction.dx][y + direction.dy]
          let b = parsedInput[x - direction.dx][y - direction.dy]
          return a == "M" && b == "S" || a == "S" && b == "M"
        }) {
          numFound += 1
        }
      }
    }

    return numFound
  }
}

func parseInput(_ input: String) -> [[Substring.Element]] {
  input.split(separator: "\n").map { line in
    line.map { $0 }
  }
}
