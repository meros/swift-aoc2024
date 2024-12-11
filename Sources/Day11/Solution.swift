import Foundation
import Utils

func parsedInput(_ input: String) -> [Int] {
  let list = input.split(separator: " ").compactMap { Int($0
          .replacingOccurrences(of: "\n", with: "")

  ) }

  return list
}

func hasEvenNumberOfDigits(_ number: Int) -> Bool {
    let digitCount = Int(log10(Double(abs(number)))) + 1
    return digitCount & 1 == 0 // Bitwise AND for checking evenness
}

func processStone(_ value: Int) -> [Int] {
  if value == 0 {
      return  [1]
    }
    
    if hasEvenNumberOfDigits(value) {
      let stringValue = String(value)
        let midIndex = stringValue.index(stringValue.startIndex, offsetBy: stringValue.count / 2)
        return [
          Int(stringValue[stringValue.startIndex..<midIndex])!,
          Int(stringValue[midIndex..<stringValue.endIndex])!]        
    }

    return [value * 2024]
}

func blink(_ stones: [Int]) -> [Int] {
  stones.flatMap { processStone($0) } 
}

struct DynamicResultKey: Hashable {
  var stone: Int
  var blinksLeft: Int
}

var dynamicResult: [DynamicResultKey: Int] = [:]
func blinkOneStoneGetNumberOfStonesCreated(_ stone: Int, _ blinksLeft: Int) -> Int {
  let dynamicResultKey = DynamicResultKey(stone: stone, blinksLeft: blinksLeft)
  if let dynamicResult = dynamicResult[dynamicResultKey] {
    return dynamicResult
  }

  if (blinksLeft == 0) {
    return 1
  }

  let blinkedStones = blink([stone])
  let result = blinkedStones.map {
    blinkOneStoneGetNumberOfStonesCreated($0, blinksLeft - 1)
  }.reduce(0, +)

  dynamicResult[dynamicResultKey] = result
  return result
}
 

public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let stones = parsedInput(input)

    return stones.map {
      blinkOneStoneGetNumberOfStonesCreated($0, 25)
    }.reduce(0, +)    
  }

  public static func solvePart2(_ input: String) async -> Int {
     let stones = parsedInput(input)

    return stones.map {
      blinkOneStoneGetNumberOfStonesCreated($0, 75)
    }.reduce(0, +)  
  }
}
