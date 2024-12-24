import Foundation
import Utils

public class Solution: Day {
  public static var onlySolveExamples: Bool = false

  public static func solvePart1(_ input: String) async -> Int {
    let (inputValues, operations) = parseCircuitFile(input)

    var result = 0
    for (output, _) in operations {
      if output.hasPrefix("z"),
        let bit = Int(String(output.dropFirst()))
      {
        let value = solve(output, operations, inputValues)
        result |= (value ? 1 : 0) << bit
      }
    }

    return result
  }
}

func solve(_ output: Name, _ operations: [Name: Operation], _ inputs: [Name: Bool]) -> Bool {
  if let value = inputs[output] {
    return value
  }

  if let operation = operations[output] {
    let input1 = solve(operation.input1, operations, inputs)
    let input2 = solve(operation.input2, operations, inputs)

    switch operation.operation {
    case .and:
      return input1 && input2
    case .or:
      return input1 || input2
    case .xor:
      return input1 != input2
    }
  }

  return false
}

typealias Operation = (input1: Substring, operation: LogicGate, input2: Substring)
typealias Name = Substring

// Define an enum for logic operations
enum LogicGate: Substring, Hashable {
  case and = "AND"
  case or = "OR"
  case xor = "XOR"
}

func parseCircuitFile(_ fileContent: String) -> (
  inputValues: [Name: Bool], operations: [Name: Operation]
) {
  // Define the regex patterns
  let inputPattern = #/(?<key>x\d{2}|y\d{2}): (?<value>\d+)/#
  let operationPattern =
    #/(?<input1>\w{3}) (?<gate>AND|OR|XOR) (?<input2>\w{3}) -> (?<output>\w{3})/#

  var inputValues: [Name: Bool] = [:]
  var operations: [Name: Operation] = [:]

  // Parse input values
  for match in fileContent.matches(of: inputPattern) {
    let key = match.output.key
    let value = match.output.value

    if let intValue = Int(value) {
      inputValues[key] = intValue == 1
    }
  }

  // Parse operations
  for match in fileContent.matches(of: operationPattern) {
    let input1 = match.output.input1
    let gate = match.output.gate
    let input2 = match.output.input2
    let output = match.output.output

    if let operation = LogicGate.init(rawValue: gate) {
      operations[output] = (input1: input1, operation: operation, input2: input2)
    }
  }

  return (inputValues, operations)
}
