import Foundation
import Utils

func parseInitialStones(_ input: String) -> [Int] {
  input.matches(of: #/([0-9]+)/#).compactMap { Int($0.output.1) }    
}

func hasEvenNumberOfDigits(_ number: Int) -> Bool {
  let digitCount = Int(log10(Double(abs(number)))) + 1
  return digitCount & 1 == 0 
}

func transformStone(_ stoneNumber: Int) -> [Int] {
  if stoneNumber == 0 {
    // Rule 1: Replace 0 with 1
    return [1]
  }
    
  if hasEvenNumberOfDigits(stoneNumber) {
    // Rule 2: Split even-digit numbers into two stones
    let stringValue = String(stoneNumber)
    let midIndex = stringValue.index(stringValue.startIndex, offsetBy: stringValue.count / 2)
    return [
      Int(stringValue[stringValue.startIndex..<midIndex])!,
      Int(stringValue[midIndex..<stringValue.endIndex])!
    ]        
  }

  // Rule 3: Multiply by 2024
  return [stoneNumber * 2024]
}

func simulateBlink(_ stones: [Int]) -> [Int] {
  stones.flatMap { transformStone($0) } 
}

struct BlinkCacheKey: Hashable {
  var stoneNumber: Int
  var blinksRemaining: Int
}

var blinkCache: [BlinkCacheKey: Int] = [:]
func countStonesAfterBlinks(_ stoneNumber: Int, _ blinksRemaining: Int) -> Int {
  if blinksRemaining == 0 {
    return 1
  }

  let key = BlinkCacheKey(stoneNumber: stoneNumber, blinksRemaining: blinksRemaining)
  if let cachedResult = blinkCache[key] {
    return cachedResult
  }

  let totalNewStones = simulateBlink([stoneNumber]).map {
    countStonesAfterBlinks($0, blinksRemaining - 1)
  }.reduce(0, +)

  blinkCache[key] = totalNewStones
  return totalNewStones
}

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let initialStones = parseInitialStones(input)
    return initialStones.map {
      countStonesAfterBlinks($0, 25)
    }.reduce(0, +)    
  }

  public static func solvePart2(_ input: String) async -> Int {
    let initialStones = parseInitialStones(input)
    return initialStones.map {
      countStonesAfterBlinks($0, 75)
    }.reduce(0, +)  
  }
}