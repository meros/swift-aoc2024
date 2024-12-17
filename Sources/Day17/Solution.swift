import Foundation
import Utils

public struct Solution: Day {
  public static var facitPart1: Int = 0

  public static var facitPart2: Int = 258394985014171

  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let machine = parseMachine(input)

    let output = run(machine)

    // Convert to string and join with ,
    print(output.map { String($0) }.joined(separator: ","), "expected: 2,1,4,0,7,4,0,2,3")
    return 0
  }

  public static func solvePart2(_ input: String) async -> Int {
    let machine = parseMachine(input)
    let oldDesired = [7, 5, 5, 3, 0]
    let oldI = 0b1110_10110000
    return solveRecursive(machine, oldDesired, oldI) ?? 0
  }
}

struct Machine {
  let a: Int
  let b: Int
  let c: Int
  let instructions: [Int]
}

func parseMachine(_ input: String) -> Machine {
  let matchA = input.firstMatch(of: #/Register A: (?<val>\d+)/#)!
  let matchB = input.firstMatch(of: #/Register B: (?<val>\d+)/#)!
  let matchC = input.firstMatch(of: #/Register C: (?<val>\d+)/#)!

  let matchInstructions = input.firstMatch(of: #/Program: (?<instructions>.+)/#)!
  let instructions = matchInstructions.output.instructions.split(separator: ",").map { Int($0)! }

  return Machine(
    a: Int(matchA.output.val)!, b: Int(matchB.output.val)!, c: Int(matchC.output.val)!,
    instructions: instructions)
}

func run(_ machine: Machine, _ desired: [Int]? = nil) -> [Int] {
  var programCounter = 0
  var output = [Int]()

  var a = machine.a
  var b = machine.b
  var c = machine.c

  while programCounter != machine.instructions.endIndex {
    var progress = true

    let opcode = machine.instructions[programCounter]
    let litop = machine.instructions[programCounter + 1]
    let comboop =
      switch litop {
      case 0...3:
        // Combo operands 0 through 3 represent literal values 0 through 3.
        litop
      case 4:
        // Combo operand 4 represents the value of register A.
        a
      case 5:
        // Combo operand 5 represents the value of register B.
        b
      case 6:
        // Combo operand 6 represents the value of register C.
        c
      default:
        // Combo operand 7 is reserved and will not appear in valid programs.
        0
      }

    switch opcode {
    case 0:
      // The adv instruction (opcode 0) performs division. The numerator is the value in the A register. The denominator is found by raising 2 to the power of the instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.) The result of the division operation is truncated to an integer and then written to the A register.
      let divisor = Int(pow(2, Double(comboop)))
      a /= divisor
    case 1:
      // The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the instruction's literal operand, then stores the result in register B.
      b ^= litop
    case 2:
      // The bst instruction (opcode 2) calculates the value of its combo operand modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to the B register.
      b = comboop % 8
    case 3:
      // The jnz instruction (opcode 3) does nothing if the A register is 0. However, if the A register is not zero, it jumps by setting the instruction pointer to the value of its literal operand; if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.
      if a != 0 {
        progress = programCounter == litop
        programCounter = litop
      }
    case 4:
      // The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C, then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)
      b ^= c
    case 5:
      // Check if we should exit early
      if let desired = desired, desired[output.count] != comboop % 8 {
        return output
      }

      // The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value. (If a program outputs multiple values, they are separated by commas.)
      output.append(comboop % 8)
    case 6:
      //The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register. (The numerator is still read from the A register.)
      let divisor = Int(pow(2, Double(comboop)))
      b = a / divisor
     case 7:
      // The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register. (The numerator is still read from the A register.)
      let divisor = Int(pow(2, Double(comboop)))
      c = a / divisor
    default:
      break
    }

    if progress {
      programCounter += 2
    }
  }

  return output
}

func solveRecursive(_ originalMachine: Machine, _ desired: [Int], _ partialSolution: Int) -> Int? {
  for potentialSolution in (partialSolution << 3)..<(partialSolution << 3 + 7) {
    let machine = Machine(
      a: potentialSolution, b: originalMachine.b, c: originalMachine.c,
      instructions: originalMachine.instructions)

    if run(machine, Array(desired)) == desired {
      if Array(desired) == machine.instructions {
        return potentialSolution
      }

      let nextDesired = 
          Array(machine.instructions[
            machine.instructions.endIndex - (desired.count + 1)..<machine.instructions.endIndex])
      if let completeSolution = solveRecursive(
        originalMachine,
        nextDesired,
        potentialSolution)
      {
        return completeSolution
      }
    }
  }

  return nil
}
