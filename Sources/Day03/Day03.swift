import DayUtils
import Foundation

let pattern = #/mul\(([0-9]{1,3}),([0-9]{1,3})\)|do\(\)|don't\(\)/#

func getProduct(_ match: Regex<Regex<(Substring, Substring?, Substring?)>.RegexOutput>.Match) -> Int
{
    if let factor1Substring = match.output.1,
        let factor2Substring = match.output.2,
        let factor1 = Int(factor1Substring),
        let factor2 = Int(factor2Substring)
    {
        return factor1 * factor2
    }

    return 0
}

public struct Day03: Day {
    public static func solvePart1(_ input: String) -> Int {
        input.matches(of: pattern).reduce(into: 0) { sum, match in
            sum += getProduct(match)
        }
    }

    public static func solvePart2(_ input: String) -> Int {
        let matches = input.matches(of: pattern)

        var enabled = true
        var totalSum = 0
        for match in matches {
            let command = match.output.0
            switch command {
            case "do()":
                enabled = true
            case "don't()":
                enabled = false
            default:
                if enabled {
                    totalSum += getProduct(match)
                }
            }
        }

        return totalSum
    }
}
