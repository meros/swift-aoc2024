import Foundation
import Utils

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
    var secretNumbers = parseSecretNumbers(input)

    var offerChangesBySeller: [[(change: Int, offer: Int)]] = [
      secretNumbers.map { (change: 0, offer: $0 % 10) }
    ]
    for _ in 1...2000 {
      let next = secretNumbers.map(nextSecret)
      secretNumbers = next.map { $0.secret }

      offerChangesBySeller.append(next.map { (change: $0.change, offer: $0.offer) })
    }

    var offersByFirstSequenceFound: [[Int]: [Int?]] = [:]

    for idx in (offerChangesBySeller.startIndex + 3)..<offerChangesBySeller.endIndex {
      let sequences = offerChangesBySeller[idx - 3...idx].map { $0.map { $0.change } }.transposed()
      let offers = offerChangesBySeller[idx].map { $0 }

      for (offset, (sequence, offer)) in zip(sequences, offers).enumerated() {
        var oldOffers = offersByFirstSequenceFound[
          sequence, default: Array(repeating: nil, count: sequences.count)]

        oldOffers[offset] = oldOffers[offset] ?? offer.offer
        offersByFirstSequenceFound[sequence] = oldOffers
      }
    }

    return offersByFirstSequenceFound.map {
      sequence, offers in
      offers.compactMap { $0 }.reduce(0, +)
    }.max(by: <) ?? 0
  }
}

func parseSecretNumbers(_ input: String) -> [Int] {
  input.components(separatedBy: .newlines).compactMap(Int.init)
}

func nextSecret(_ a: Int) -> (secret: Int, offer: Int, change: Int) {
  let oldOffer = a % 10

  var secret = a

  func mixnprune(_ a: Int, _ b: Int) -> Int {
    (a ^ b) % 16_777_216  // & 0xFFFFFF
  }

  secret = mixnprune(secret, secret * 64)
  secret = mixnprune(secret, secret / 32)
  secret = mixnprune(secret, secret * 2048)

  let offer = secret % 10

  return (secret: secret, offer: offer, change: offer - oldOffer)
}

struct Key: Hashable {
  let sequence: [Int]
}
