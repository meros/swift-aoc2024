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

  public static func solvePart2String(_ input: String) async -> String {
    var (inputValues, operations) = parseCircuitFile(input)
    var validInputs: Set<Name> = []

    var bit = -1
    while true {
      bit += 1

      let output = Name.buildFromBitAndPrefix("z", bit)
      
      if operations[Name.buildFromBitAndPrefix("z", bit)] == nil {
        print ("Bit \(bit) not found, breaking")
        break
      }

      let expected = buildExpected(bit: bit)

      guard let swaps = fix(output, expected.sum, operations, inputValues, validInputs) else {
        break
      }

      if swaps.isEmpty {
        continue
      }

      for (from, to) in swaps {
        let tmp = operations[to]
        operations[to] = operations[from]
        operations[from] = tmp

        validInputs.insert(from)
        validInputs.insert(to)
      }
    }

    print("Swaps: \(validInputs)")

    return ""
  }
}

func fix(
  _ name: Name,
  _ expected: LogicOperation,
  _ operations: [Name: Operation],
  _ inputValues: [Name: Bool],
  _ invalidSwaps: Set<Name>
) -> [(Name, Name)]? {
  let actual = solve2(name, operations, inputValues)
  if expected == actual.operation {
    return []
  }

  // Check if there is another operation that can be replaced
  if let validSwapOperation = operations.first(where: {
    key, value in
    !invalidSwaps.contains(key) && solve2(key, operations, inputValues).operation == expected
  }) {
    return [(validSwapOperation.key, name)]
  }

  if case LogicOperation.operation(let operands, let gate) = actual.operation,
    case LogicOperation.operation(let expectedOperands, let expectedGate) = expected
  {
    if gate != expectedGate {
      return nil
    }

    let invalidOperands = operands.filter {
      operand in
      !expectedOperands.contains(operand)
    }

    let invalidExpectedOperands = expectedOperands.filter {
      operand in
      !operands.contains(operand)
    }

    return zip(invalidOperands, invalidExpectedOperands).map {
      (invalidOperand, invalidExpectedOperand) in

      if let invalidOperationName = operations.keys.first(where: {
        solve2($0, operations, inputValues).operation == invalidOperand
      }) {
        return fix(
          invalidOperationName, invalidExpectedOperand, operations, inputValues, invalidSwaps)
      }

      return nil
    }.compactMap { $0 }.flatMap { $0 }
  }

  return nil
}

func solve(_ output: Name, _ operations: [Name: Operation], _ inputs: [Name: Bool]) -> Bool {
  if let value = inputs[output] {
    return value
  }

  if let operation = operations[output] {
    let inputs = operation.inputs.map {
      input in
      solve(input, operations, inputs)
    }

    switch operation.operation {
    case .and:
      return inputs.reduce(true) { $0 && $1 }
    case .or:
      return inputs.reduce(false) { $0 || $1 }
    case .xor:
      return inputs.reduce(false) { $0 != $1 }
    }
  }

  return false
}

func solve2(_ output: Name, _ operations: [Name: Operation], _ inputs: [Name: Bool])
  -> (operation: LogicOperation, involvedInputs: Set<Name>)
{
  if inputs[output] != nil {
    return (operation: .value(output), [])
  }

  if let operation = operations[output] {
    let inputsValues = operation.inputs.map {
      input in
      solve2(input, operations, inputs)
    }

    switch operation.operation {
    case .and:
      return (
        operation: .operation(
          operands: Set(inputsValues.map { $0.operation }),
          operator: .and),
        involvedInputs: Set((inputsValues.flatMap { $0.involvedInputs }) + [output])
      )
    case .or:
      return (
        operation: .operation(
          operands: Set(inputsValues.map { $0.operation }),
          operator: .or),
        involvedInputs: Set((inputsValues.flatMap { $0.involvedInputs }) + [output])
      )
    case .xor:
      return (
        operation: .operation(
          operands: Set(inputsValues.map { $0.operation }),
          operator: .xor),
        involvedInputs: Set((inputsValues.flatMap { $0.involvedInputs }) + [output])
      )
    }
  }

  return (.error, [])
}

func buildExpected(bit: Int) -> (sum: LogicOperation, remainder: LogicOperation) {
  // Simple half adder
  if bit == 0 {
    return (
      sum: .operation(
        operands: Set(
          [
            Name.buildFromBitAndPrefix("x", bit),
            Name.buildFromBitAndPrefix("y", bit),
          ].map { .value($0) }),
        operator: .xor),
      remainder: .operation(
        operands: Set(
          [
            Name.buildFromBitAndPrefix("x", bit),
            Name.buildFromBitAndPrefix("y", bit),
          ].map { .value($0) }),
        operator: .and)
    )
  } else {
    let prevRemainder = buildExpected(bit: bit - 1).remainder
    let x = LogicOperation.value(Name.buildFromBitAndPrefix("x", bit))
    let y = LogicOperation.value(Name.buildFromBitAndPrefix("y", bit))

    let haSum = LogicOperation.operation(operands: Set([x, y]), operator: .xor)
    let sum = LogicOperation.operation(operands: Set([prevRemainder, haSum]), operator: .xor)

    let haRemainder = LogicOperation.operation(operands: Set([x, y]), operator: .and)
    let otherRemainder = LogicOperation.operation(
      operands: Set([prevRemainder, haSum]),
      operator: .and
    )
    let remainder = LogicOperation.operation(
      operands: Set([haRemainder, otherRemainder]), operator: .or)

    return (sum: sum, remainder: remainder)
  }
}

indirect enum LogicOperation: Hashable {
  case value(Name)
  case operation(operands: Set<LogicOperation>, operator: LogicGate)
  case error
}

extension LogicOperation: CustomStringConvertible {
  var description: String {
    switch self {
    case .value(let name):
      return "\(name)"
    case .operation(let operands, let gate):
      return "(\(operands.map { $0.description }.joined(separator: " \(gate) ")))"
    case .error:
      return "error"
    }
  }
}

typealias Operation = (operation: LogicGate, inputs: Set<Substring>)
typealias Name = Substring

extension Name {
  static func buildFromBitAndPrefix(_ prefix: String, _ bit: Int) -> Name {
    return "\(prefix)\(String(format: "%02d", bit))"
  }
}

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
      operations[output] = (operation, [input1, input2])
    }
  }

  return (inputValues, operations)
}
