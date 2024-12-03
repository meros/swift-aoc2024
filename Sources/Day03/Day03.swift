import DayUtils
import Foundation

typealias PatternType = Regex<
    (
        Substring, mul: Substring?, factor1: Substring?, factor2: Substring?, do: Substring?,
        dont: Substring?
    )
>
let pattern: PatternType =
    #/(?<mul>mul\((?<factor1>[0-9]{1,3}),(?<factor2>[0-9]{1,3})\))|(?<do>do\(\))|(?<dont>don't\(\))/#

func getProduct(_ match: PatternType.Match) -> Int {
    if match.mul != nil,
        let factor1Substring = match.factor1,
        let factor2Substring = match.factor2,
        let factor1 = Int(factor1Substring),
        let factor2 = Int(factor2Substring)
    {
        return factor1 * factor2
    }

    return 0
}

func getZero(_ _: PatternType.Match) -> Int {
    return 0
}

public struct Day03: Day {
    public static func solvePart1(_ input: String) -> Int {
        input.matches(of: pattern).map(getProduct).reduce(0, +)
    }

    public static func solvePart2(_ input: String) -> Int {
        input.matches(of: pattern).reduce(
            into: (prod: getProduct, sum: 0)
        ) { result, match in
            result.prod = match.do != nil ? getProduct : result.prod
            result.prod = match.dont != nil ? getZero : result.prod
            result.sum += result.prod(match)
        }.sum
    }
}
