import Foundation
import Utils

let maxDelta = 18

public class Solution: Day {
  public static var facitPart1: Int = 20_411_980_517

  public static var facitPart2: Int = 2362

  public static var onlySolveExamples: Bool = false

  public static func solvePart1(_ input: String) -> Int {
    let numbers = parseSecretNumbers(input)

    return numbers.map({
      var result = $0

      for _ in 1...2000 {
        result = nextSecret(result).secret
      }

      return result
    }).reduce(0, +)
  }
    
  public static func solvePart2(_ input: String) -> Int {
    var secretNumbers = parseSecretNumbers(input).map {
      (secret: $0, offer: $0 % 10, change: 0)
    }

    var sequencesOfFour: [Int] = Array(repeating: 0, count: secretNumbers.count)
    var offersByFirstSequenceFound: [[Int?]] = Array(
      repeating: Array(repeating: nil, count: secretNumbers.count), count: maxDelta * maxDelta * maxDelta * maxDelta)

    for idx in 1...2000 {
      secretNumbers = secretNumbers.map { nextSecret($0.secret) }

      for sellerIndex in 0..<secretNumbers.count {
        sequencesOfFour[sellerIndex] *= maxDelta
        sequencesOfFour[sellerIndex] %= maxDelta * maxDelta * maxDelta * maxDelta
        sequencesOfFour[sellerIndex] += (secretNumbers[sellerIndex].change + maxDelta / 2)

        if idx >= 4 {
          let key = sequencesOfFour[sellerIndex]

          offersByFirstSequenceFound[key][sellerIndex] =
            offersByFirstSequenceFound[key][sellerIndex]
            ?? secretNumbers[sellerIndex].offer
        }
      }
    }
    
    return offersByFirstSequenceFound.map { $0.compactMap { $0 }.reduce(0, +) }.max(by: <) ?? 0
  }
}

func parseSecretNumbers(_ input: String) -> [Int] {
  input.components(separatedBy: .newlines).compactMap(Int.init)
}

func nextSecret(_ a: Int) -> (secret: Int, offer: Int, change: Int) {
  let oldOffer = a % 10

  var secret = a

  func mixnprune(_ a: Int, _ b: Int) -> Int {
    (a ^ b) & 0xFFFFFF
  }

  secret = mixnprune(secret, secret * 64)
  secret = mixnprune(secret, secret / 32)
  secret = mixnprune(secret, secret * 2048)

  let offer = secret % 10

  return (secret: secret, offer: offer, change: offer - oldOffer)
}
