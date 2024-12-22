import Foundation
import Utils

struct DayLoader: Sequence {
  struct DayIterator: IteratorProtocol {
    private var current = 1
    private let maxDay = 25

    mutating func next() -> (Day.Type, Int)? {
      while current <= maxDay {
        if let day = DayLoader.loadDay(current) {
          current += 1
          return day
        }
        current += 1
      }

      return nil
    }
  }

  static func loadDay(_ dayNum: Int) -> (Day.Type, Int)? {
    let className = String(format: "Day%02d.Solution", dayNum)
    let day = NSClassFromString(className) as? Day.Type
    return day.map { ($0, dayNum) }
  }

  func makeIterator() -> DayIterator {
    DayIterator()
  }
}

// MARK: - Day Extension
extension Day {
  static func run(withSession session: String, withDaynum dayNum: Int) async {
    let exampleInput = getExampleInput(dayNum)
    let input = await getInput(dayNum, session)

    print(Self.onlySolveExamples)
    if !Self.onlySolveExamples, let input = input {
      print("🎄 Solutions for Day \(dayNum):")

      let startPart1 = Date()
      let solutionPart1 = await solvePart1String(input)
      let endPart1 = Date()
      print(
        "🎯 Part 1: \(solutionPart1) ⏱️ \(String(format: "%.3f", endPart1.timeIntervalSince(startPart1)))s \(solutionPart1 == facitPart1String ? "🎅" : "❌")"
      )

      let startPart2 = Date()
      let solutionPart2 = await solvePart2String(input)
      let endPart2 = Date()
      print(
        "🎯 Part 2: \(solutionPart2) ⏱️ \(String(format: "%.3f", endPart2.timeIntervalSince(startPart2)))s \(solutionPart2 == facitPart2String ? "🎅" : "❌")"
      )

      return
    }

    if let exampleInput = exampleInput {
      print("\n🌟 Example input:")
      let part1 = await solvePart1String(exampleInput)
      let part2 = await solvePart2String(exampleInput)
      print("🎁 Part 1: \(part1)")
      print("🎁 Part 2: \(part2)\n")
    }
  }
}

// MARK: - Main
let christmasTree = """
      🎄
     🎄🎄
    🎄🎄🎄
   🎄🎄🎄🎄
  🎄🎄🎄🎄🎄
      🎁
  """

print("\n\(christmasTree)")
print("🎄 ⭐️ Welcome to Advent of Code 2024! ⭐️ 🎄")
print("🎅 Ho ho ho! Let's solve some puzzles! 🎅\n")

guard let session = readSessionFromFile() else {
  print("❄️ No session cookie found in Santa's workshop! ❄️")
  exit(1)
}

let dayLoader = DayLoader()
if let requestedDay = CommandLine.arguments.dropFirst().first.flatMap(Int.init) {
  if let day = DayLoader.loadDay(requestedDay) {
    await day.0.run(withSession: session, withDaynum: day.1)
  } else {
    print("🎅 Ho ho ho! Day \(requestedDay) is still wrapped up under the tree! 🎁")
  }
} else {
  for day in dayLoader {
    await day.0.run(withSession: session, withDaynum: day.1)
  }
}
