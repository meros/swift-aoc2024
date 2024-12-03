import DayUtils
import Foundation

let pattern = #"mul\(([0-9]{1,3}),([0-9]{1,3})\)|do\(\)|don't\(\)"#

func getProduct(match: NSTextCheckingResult, input: String) -> Int {
    if let range1 = Range(match.range(at: 1), in: input),
        let range2 = Range(match.range(at: 2), in: input),
        let num1 = Int(input[range1]),
        let num2 = Int(input[range2])
    {
        return num1 * num2
    }

    return 0
}

public struct Day03: Day {
    public static func solvePart1(_ input: String) -> Int {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(
            in: input, options: [], range: NSRange(input.startIndex..., in: input))

        var totalSum = 0

        for match in matches {
            totalSum += getProduct(match: match, input: input)
        }

        return totalSum
    }

    public static func solvePart2(_ input: String) -> Int {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(
            in: input, options: [], range: NSRange(input.startIndex..., in: input))

        var enabled = true
        var totalSum = 0
        for match in matches {
            if let range = Range(match.range(at: 0), in: input) {
                let matchString = input[range]
                switch matchString {
                case "do()":
                    enabled = true
                    break
                case "don't()":
                    enabled = false
                    break
                default:
                    if !enabled {
                        break
                    }

                    totalSum += getProduct(match: match, input: input)
                    break
                }
            }
        }

        return totalSum
    }
}
