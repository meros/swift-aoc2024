import Foundation
import Utils

public struct Solution: Day {
  public static var facitPart1: Int = 0

  public static var facitPart2: Int = 0

  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    var machine = parseMachine(input)

    while step(&machine) == .run {
    }

    // Convert to string and join with ,
    print(machine.output.map { String($0) }.joined(separator: ","))

    return 0
  }

  public static func solvePart2(_ input: String) async -> Int {
    let originalMachine = parseMachine(input)

    for i in 0...Int.max {
      if i % 1000000 == 0 {
        print(i, Int.max)
      }

      var machine = originalMachine
      machine.a = i
      while true {
        let stepResult = step(&machine, true)
        if stepResult == .run {
          continue
        }

        if stepResult == .earlyExit {
          break
        }

        if stepResult == .done {
          if machine.output == machine.instructions {
            return i
          }

          break
        }
      }
    }

    return 0
  }
}

struct Machine {
  var a: Int
  var b: Int
  var c: Int
  let instructions: [Int]
  var programCounter: Array<Int>.Index = 0
  var output: [Int] = []
}

func parseMachine(_ input: String) -> Machine {
  let matchA = input.firstMatch(of: #/Register A: (?<val>\d+)/#)!
  let matchB = input.firstMatch(of: #/Register B: (?<val>\d+)/#)!
  let matchC = input.firstMatch(of: #/Register C: (?<val>\d+)/#)!
  //Program: 2,4,1,7,7,5,0,3,4,0,1,7,5,5,3,0

  let matchInstructions = input.firstMatch(of: #/Program: (?<instructions>.+)/#)!
  let instructions = matchInstructions.output.instructions.split(separator: ",").map { Int($0)! }

  return Machine(
    a: Int(matchA.output.val)!, b: Int(matchB.output.val)!, c: Int(matchC.output.val)!,
    instructions: instructions)
}

enum MachineStep {
  case done
  case run
  case earlyExit
}

func step(_ machine: inout Machine, _ checkOutput: Bool = false) -> MachineStep {
  var progress = true

  let opcode = machine.instructions[machine.programCounter]
  let litop = machine.instructions[machine.programCounter + 1]
  let comboop =
    switch litop % 8 {
    case 0...3:
      // Combo operands 0 through 3 represent literal values 0 through 3.
      litop
    case 4:
      // Combo operand 4 represents the value of register A.
      machine.a
    case 5:
      // Combo operand 5 represents the value of register B.
      machine.b
    case 6:
      // Combo operand 6 represents the value of register C.
      machine.c
    default:
      // Combo operand 7 is reserved and will not appear in valid programs.
      0
    }

  switch opcode {
  case 0:
    // The adv instruction (opcode 0) performs division. The numerator is the value in the A register. The denominator is found by raising 2 to the power of the instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.) The result of the division operation is truncated to an integer and then written to the A register.
    let divisor = Int(pow(2, Double(comboop)))
    machine.a /= divisor
  case 1:
    // The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the instruction's literal operand, then stores the result in register B.
    machine.b ^= litop
  case 2:
    // The bst instruction (opcode 2) calculates the value of its combo operand modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to the B register.
    machine.b = comboop % 8
  case 3:
    // The jnz instruction (opcode 3) does nothing if the A register is 0. However, if the A register is not zero, it jumps by setting the instruction pointer to the value of its literal operand; if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.
    if machine.a != 0 {
      progress = machine.programCounter == litop
      machine.programCounter = litop
    }
  case 4:
    // The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C, then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)
    machine.b ^= machine.c
  case 5:
    // The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value. (If a program outputs multiple values, they are separated by commas.)
    machine.output.append(comboop % 8)
    if checkOutput && machine.instructions[0..<machine.output.count] != machine.output[...] {
      return .earlyExit
    }
  case 6:
    //The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register. (The numerator is still read from the A register.)
    let divisor = Int(pow(2, Double(comboop)))
    machine.b = machine.a / divisor
  case 7:
    // The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register. (The numerator is still read from the A register.)
    let divisor = Int(pow(2, Double(comboop)))
    machine.c = machine.a / divisor
  default:
    break
  }

  if progress {
    machine.programCounter += 2
  }

  return machine.programCounter == machine.instructions.endIndex ? .done : .run
}
