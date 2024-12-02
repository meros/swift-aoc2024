import Day01
import Day02
import DayUtils
import Foundation

print("🎄🎅 Welcome to Advent of Code 2024! 🎅🎄")

func getCurrentDay() -> Int {
    let date = Date()
    let calendar = Calendar.current
    return calendar.component(.day, from: date)
}

func runDay(_ day: Int) {
    let dayImplementation: Day.Type?
    switch day {
    case 1:
        dayImplementation = Day01.self
    case 2:
        dayImplementation = Day02.self
    default:
        dayImplementation = nil
    }

    guard let unwrappedDayImplementation = dayImplementation else {
        print("Day \(day) not implemented yet.")
        return
    }

    let url = URL(fileURLWithPath: String(format: "./Input/Day%02d/input", day))
    do {
        let input = try String(contentsOf: url)
        print("Solution day \(day), part 1: \(unwrappedDayImplementation.solvePart1(input))")
        print("Solution day \(day), part 2: \(unwrappedDayImplementation.solvePart2(input))")
    } catch {
        print("Error reading input for day \(day): \(error)")
    }
}

let arguments = CommandLine.arguments
let day: Int

if arguments.count > 1, let inputDay = Int(arguments[1]) {
    day = inputDay
} else {
    day = getCurrentDay()
}

runDay(day)
