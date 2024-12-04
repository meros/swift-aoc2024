import DayUtils
import Foundation

func parseInput(_ input: String) -> [[Substring.Element]] {
    input.split(separator: "\n").map { line in
        line.map { $0 }
    }
}

let word: String = "XMAS"
func checkForWordAt(_ input: [[Substring.Element]], _ x: Int, _ y: Int) -> Int {
    let xMax = input.count
    let yMax = input[x].count

    var found = 0

    let directions = [
        (dx: 0, dy: 1),  // right
        (dx: 1, dy: 0),  // down
        (dx: 0, dy: -1),  // left
        (dx: -1, dy: 0),  // up
        (dx: 1, dy: 1),  // diagonal down right
        (dx: 1, dy: -1),  // diagonal down left
        (dx: -1, dy: 1),  // diagonal up right
        (dx: -1, dy: -1),  // diagonal up left
    ]

    for direction in directions {
        var foundString = ""
        var valid = true

        for i in 0..<word.count {
            let newX = x + i * direction.dx
            let newY = y + i * direction.dy

            if newX >= 0 && newX < xMax && newY >= 0 && newY < yMax {
                foundString.append(input[newX][newY])
            } else {
                valid = false
                break
            }
        }

        if valid && foundString == word {
            found += 1
        }
    }

    return found
}

let crossWord = "MAS"
func checkForMasFromA(
    _ input: [[Substring.Element]], _ aX: Int, _ aY: Int, _ direction: (dx: Int, dy: Int)
)
    -> Bool
{
    let yMax = input.count
    let xMax = input[0].count

    let x = aX - direction.dx
    let y = aY - direction.dy

    var foundString = ""
    for i in 0..<crossWord.count {
        let newX = x + i * direction.dx
        let newY = y + i * direction.dy

        if newX >= 0 && newX < xMax && newY >= 0 && newY < yMax {
            foundString.append(input[newX][newY])
        } else {
            return false
        }
    }

    return foundString == crossWord
}

func checkForMaxCrossAtA(_ input: [[Substring.Element]], _ x: Int, _ y: Int) -> Int {
    var found = 0

    let directions = [
        (dx: 1, dy: 1),  // diagonal down right
        (dx: -1, dy: -1),  // diagonal up left
        (dx: 1, dy: -1),  // diagonal down left
        (dx: -1, dy: 1),  // diagonal up right
    ]

    for direction in directions {
        if !checkForMasFromA(input, x, y, direction) {
            continue
        }

        let nintyDegrees = (dx: -direction.dx, dy: direction.dy)
        let nintyDegreesOpposite = (dx: direction.dx, dy: -direction.dy)

        if checkForMasFromA(input, x, y, nintyDegrees)
            || checkForMasFromA(
                input, x, y,
                nintyDegreesOpposite)
        {
            found += 1
            break;
        }
    }

    return found
}

public struct Day04: Day {
    public static func solvePart1(_ input: String) -> Int {
        let parsedInput = parseInput(input)

        var numFound = 0
        for x in 0..<parsedInput.count {
            for y in 0..<parsedInput[x].count {
                if parsedInput[x][y] == word.first {
                    numFound += checkForWordAt(parsedInput, x, y)
                }
            }
        }

        return numFound
    }

    public static func solvePart2(_ input: String) -> Int {
        let parsedInput = parseInput(input)

        var numFound = 0
        for x in 0..<parsedInput.count {
            for y in 0..<parsedInput[x].count {
                if parsedInput[x][y] == "A" {
                    numFound += checkForMaxCrossAtA(parsedInput, x, y)
                }
            }
        }

        return numFound
    }
}
