import DayUtils
import Foundation

func parseInput(_ input: String) -> [[Substring.Element]] {
  input.split(separator: "\n").map { line in
    line.map { $0 }
  }
}

public struct Day04: Day {
  public static func solvePart1(_ input: String) -> Int {
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

          if lastX < 0 || lastX >= parsedInput.count || lastY < 0 || lastY >= parsedInput[x].count
            || !(0..<word.count).allSatisfy({ i in
              parsedInput[x + i * direction.dx][y + i * direction.dy]
                == word[word.index(word.startIndex, offsetBy: i)]
            })
          {
            continue
          }

          numFound += 1
        }
      }
    }
    return numFound
  }

  public static func solvePart2(_ input: String) -> Int {
    let parsedInput = parseInput(input)

    var numFound = 0
    for x in 1..<parsedInput.count - 1 {
      for y in 1..<parsedInput[x].count - 1 {
        if parsedInput[x][y] != "A" {
          continue
        }

        let directions = [(dx: 1, dy: 1), (dx: 1, dy: -1)]
        if directions.allSatisfy({ direction in
          (parsedInput[x + direction.dx][y + direction.dy] == "M"
            && parsedInput[x - direction.dx][y - direction.dy] == "S")
            || (parsedInput[x + direction.dx][y + direction.dy] == "S"
              && parsedInput[x - direction.dx][y - direction.dy] == "M")
        }) {
          numFound += 1
        }
      }
    }

    return numFound
  }
}
