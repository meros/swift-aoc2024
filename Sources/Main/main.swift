import Day01
import Day02
import Day03
import Day04
import Day05
import Day06
import Day07
import Day08
import Day09
import Day10
import Day11
import Day12
import Day13
import Day14
import Day15
import Day16
import Foundation
import Utils

var session = ""

func readSessionFromFile() -> String? {
  let fileURL = URL(fileURLWithPath: ".session")
  return try? String(contentsOf: fileURL, encoding: .utf8).trimmingCharacters(
    in: .whitespacesAndNewlines)
}

// Add at start of file
let christmasTree = """
      🎄
     🎄🎄
    🎄🎄🎄
   🎄🎄🎄🎄
  🎄🎄🎄🎄🎄
      🎁
  """

// Replace print statements with:
print("\n\(christmasTree)")
print("🎄 ⭐️ Welcome to Advent of Code 2024! ⭐️ 🎄")
print("🎅 Ho ho ho! Let's solve some puzzles! 🎅\n")

func getCurrentDay() -> Int {
  let date = Date()
  let calendar = Calendar.current
  return calendar.component(.day, from: date)
}

func runDay(_ day: Int) async {
  let dayImplementation: Day.Type?
  switch day {
  case 1:
    dayImplementation = Day01.Solution.self
  case 2:
    dayImplementation = Day02.Solution.self
  case 3:
    dayImplementation = Day03.Solution.self
  case 4:
    dayImplementation = Day04.Solution.self
  case 5:
    dayImplementation = Day05.Solution.self
  case 6:
    dayImplementation = Day06.Solution.self
  case 7:
    dayImplementation = Day07.Solution.self
  case 8:
    dayImplementation = Day08.Solution.self
  case 9:
    dayImplementation = Day09.Solution.self
  case 10:
    dayImplementation = Day10.Solution.self
  case 11:
    dayImplementation = Day11.Solution.self
  case 12:
    dayImplementation = Day12.Solution.self
  case 13:
    dayImplementation = Day13.Solution.self
  case 14:
    dayImplementation = Day14.Solution.self
  case 15:
    dayImplementation = Day15.Solution.self
  case 16:
    dayImplementation = Day16.Solution.self
  default:
    dayImplementation = nil
  }

  let exampleInput = getExampleInput(day)
  let input = await getInput(day, session)

  guard let unwrappedDayImplementation = dayImplementation else {
    print("🎅 Ho ho ho! Day \(day) is still wrapped up under the tree! 🎁")
    return
  }

  if !unwrappedDayImplementation.onlySolveExamples {
    if let input = input {
      print("🎄 Solutions for Day \(day):")
      let startPart1 = Date()
      let solutionPart1 = await unwrappedDayImplementation.solvePart1(input)
      let facitPart1 = unwrappedDayImplementation.facitPart1
      let endPart1 = Date()
      let durationPart1 = endPart1.timeIntervalSince(startPart1)
      print(
        "🎯 Part 1: \(solutionPart1) ⏱️ Solved in \(String(format: "%.3f", durationPart1))s \(solutionPart1 == facitPart1 ? "(🎅 Correct!)" : "(❌ Incorrect!)")"
      )

      let startPart2 = Date()
      let solutionPart2 = await unwrappedDayImplementation.solvePart2(input)
      let facitPart2 = unwrappedDayImplementation.facitPart2
      let endPart2 = Date()
      let durationPart2 = endPart2.timeIntervalSince(startPart2)
      print(
        "🎯 Part 2: \(solutionPart2) ⏱️ Solved in \(String(format: "%.3f", durationPart2))s \(solutionPart2 == facitPart2 ? "(🎅 Correct!)" : "(❌ Incorrect!)")"
      )
    }
  } else {
    if let exampleInput = exampleInput {
      print("🌟 Testing with example input for Day \(day):")
      let exampleSolutionPart1 = await unwrappedDayImplementation.solvePart1(exampleInput)
      print("🎁 Part 1: \(exampleSolutionPart1)")

      let exampleSolutionPart2 = await unwrappedDayImplementation.solvePart2(exampleInput)
      print("🎁 Part 2: \(exampleSolutionPart2)\n")
    }
  }
}

let arguments = CommandLine.arguments
let day: Int?

if arguments.count > 1, let inputDay = Int(arguments[1]) {
  day = inputDay
} else {
  day = nil
}

if let sessionFromFile = readSessionFromFile() {
  session = sessionFromFile
} else {
  print("❄️ No session cookie found in Santa's workshop! ❄️")
  exit(1)
}

if let day = day {
  await runDay(day)
} else {
  for day in 1...16 {
    await runDay(day)
  }
}
