import Foundation

import Day01
import Day02

// Console log "Welcome to Advent of Code 2024!" with emojis
print("🎄🎅 Welcome to Advent of Code 2024! 🎅🎄")

// Function to get the current day
func getCurrentDay() -> Int {
    let date = Date()
    let calendar = Calendar.current
    return calendar.component(.day, from: date)
}

// Function to run the specific day's code
func runDay(_ day: Int) {
    switch day {
    case 1:
        print("Solution day 1, part 1: ", Day01.solvePart1())
        print("Solution day 1, part 2: ", Day01.solvePart2())
    case 2:
        print("Solution day 2, part 1: ", Day02.solvePart1())
        print("Solution day 2, part 2: ", Day02.solvePart2())
    default:
        print("❌ Day \(day) is not implemented yet. ❌")
    }
}

// Check for command-line arguments
let arguments = CommandLine.arguments
let day: Int

if arguments.count > 1, let inputDay = Int(arguments[1]) {
    day = inputDay
} else {
    day = getCurrentDay()
}

// Run the specific day's code
runDay(day)