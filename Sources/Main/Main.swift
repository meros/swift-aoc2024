import Day01
import Day02
import Day03
import Day04
import Day05
import Day06
import Foundation
import Utils

var session = ""

func readSessionFromFile() -> String? {
  let fileURL = URL(fileURLWithPath: ".session")
  return try? String(contentsOf: fileURL, encoding: .utf8).trimmingCharacters(
    in: .whitespacesAndNewlines)
}

print("🎄🎅 Welcome to Advent of Code 2024! 🎅🎄")

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
  default:
    dayImplementation = nil
  }

  guard let unwrappedDayImplementation = dayImplementation else {
    print("Day \(day) not implemented yet.")
    return
  }

  let exampleInput = getExampleInput(day)
  if let exampleInput = exampleInput {
    let exampleSolutionPart1 = unwrappedDayImplementation.solvePart1(exampleInput)
    let exampleSolutionPart2 = unwrappedDayImplementation.solvePart2(exampleInput)

    print("Example solution day \(day), part 1: \(exampleSolutionPart1)")
    print("Example solution day \(day), part 2: \(exampleSolutionPart2)")
  }

  let input = await getInput(day, session)
  if let input = input {
    let solutionPart1 = unwrappedDayImplementation.solvePart1(input)
    let solutionPart2 = unwrappedDayImplementation.solvePart2(input)

    print("Solution day \(day), part 1: \(solutionPart1)")
    print("Solution day \(day), part 2: \(solutionPart2)")
  }
}

let arguments = CommandLine.arguments
let day: Int

if arguments.count > 1, let inputDay = Int(arguments[1]) {
  day = inputDay
} else {
  day = getCurrentDay()
}

if let sessionFromFile = readSessionFromFile() {
  session = sessionFromFile
} else {
  print("No session file found.")
  exit(1)
}

await runDay(day)
