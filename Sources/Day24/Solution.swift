import Foundation
import Utils

public class Solution: Day {
  public static var onlySolveExamples: Bool = false

  public static var facitPart1: Int = 47_666_458_872_582

  public static var facitPart2String: String = "dnt,gdf,gwc,jst,mcm,z05,z15,z30"

  public static func solvePart1(_ input: String) async -> Int {
    let (signals, gates) = parseCircuit(input)

    var result = 0
    for (wireID, _) in gates {
      if wireID.hasPrefix("z"),
        let bit = Int(String(wireID.dropFirst()))
      {
        let value = evaluateCircuit(wireID, gates, signals)
        result |= (value ? 1 : 0) << bit
      }
    }

    return result
  }

  public static func solvePart2String(_ input: String) async -> String {
    var (_, gates) = parseCircuit(input)
    var validInputs: Set<WireID> = []

    let remainderOnlyBit =
      gates.keys
      .filter { $0.hasPrefix("z") }
      .compactMap { Int(String($0.dropFirst())) }
      .max() ?? 0

    for bit in 0...remainderOnlyBit {
      let wireID = WireID.makeID("z", bit)

      if gates[WireID.makeID("z", bit)] == nil {
        print("Bit \(bit) not found, breaking")
        break
      }

      let expectedExpression = buildAdderCircuit(bit, remainderOnlyBit)

      guard let swaps = repairCircuit(wireID, expectedExpression.sum, gates, validInputs) else {
        print("No solution found for bit \(bit)")
        break
      }

      if swaps.isEmpty {
        continue
      }

      for (from, to) in swaps {
        let tmp = gates[to]
        gates[to] = gates[from]
        gates[from] = tmp

        validInputs.insert(from)
        validInputs.insert(to)
      }
    }

    return validInputs.sorted().joined(separator: ",")
  }
}

private func repairCircuit(
  _ output: WireID,
  _ expected: LogicExpression,
  _ gates: [WireID: LogicGate],
  _ validSwaps: Set<WireID>
) -> [(WireID, WireID)]? {
  // I am pretty sure this repair function doesn't cover all general cases. 
  // But it was enough to solve the problem.

  let actual = buildExpression(output, gates)
  if expected == actual {
    return []
  }

  // Check if there is another operation that can be replaced
  if let validSwapOperation = gates.first(where: {
    key, value in
    !validSwaps.contains(key) && buildExpression(key, gates) == expected
  }) {
    return [(validSwapOperation.key, output)]
  }

  if case LogicExpression.gate(let operands, let gate) = actual,
    case LogicExpression.gate(let expectedOperands, let expectedGate) = expected
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
      (invalidOperand, invalidExpectedOperand) -> [(WireID, WireID)]? in

      guard
        let invalidOperationName = gates.keys.first(where: {
          buildExpression($0, gates) == invalidOperand
        })
      else { return nil }

      return repairCircuit(invalidOperationName, invalidExpectedOperand, gates, validSwaps)
    }.compactMap { $0 }.flatMap { $0 }
  }

  return nil
}

private func evaluateCircuit(
  _ output: WireID, _ gates: [WireID: LogicGate], _ signals: [WireID: Bool]
) -> Bool {
  if let value = signals[output] {
    return value
  }

  if let operation = gates[output] {
    let inputs = operation.inputs.map {
      input in
      evaluateCircuit(input, gates, signals)
    }

    switch operation.gate {
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

private func buildExpression(_ output: WireID, _ gates: [WireID: LogicGate])
  -> LogicExpression
{
  if let operation = gates[output] {
    let inputsValues = operation.inputs.map { buildExpression($0, gates) }

    return switch operation.gate {
    case .and: .gate(inputs: Set(inputsValues), type: .and)
    case .or: .gate(inputs: Set(inputsValues), type: .or)
    case .xor: .gate(inputs: Set(inputsValues), type: .xor)
    }
  }

  return .signal(output)
}

private func buildAdderCircuit(_ bit: Int, _ maxBit: Int) -> (
  sum: LogicExpression, carry: LogicExpression
) {
  // Simple half adder
  if bit == 0 {
    return (
      sum: .gate(
        inputs: Set(
          [
            WireID.makeID("x", bit),
            WireID.makeID("y", bit),
          ].map { .signal($0) }),
        type: .xor),
      carry: .gate(
        inputs: Set(
          [
            WireID.makeID("x", bit),
            WireID.makeID("y", bit),
          ].map { .signal($0) }),
        type: .and)
    )
  } else if bit == maxBit {
    let sum = buildAdderCircuit(bit - 1, maxBit).carry
    return (sum: sum, carry: .signal(WireID.makeID("x", bit)))
  } else {
    let prevCarry = buildAdderCircuit(bit - 1, maxBit).carry
    let x = LogicExpression.signal(WireID.makeID("x", bit))
    let y = LogicExpression.signal(WireID.makeID("y", bit))

    let haSum = LogicExpression.gate(inputs: Set([x, y]), type: .xor)
    let sum = LogicExpression.gate(inputs: Set([prevCarry, haSum]), type: .xor)

    let haCarry = LogicExpression.gate(inputs: Set([x, y]), type: .and)
    let otherCarry = LogicExpression.gate(
      inputs: Set([prevCarry, haSum]),
      type: .and
    )
    let carry = LogicExpression.gate(
      inputs: Set([haCarry, otherCarry]), type: .or)

    return (sum: sum, carry: carry)
  }
}

private indirect enum LogicExpression: Hashable {
  case signal(WireID)
  case gate(inputs: Set<LogicExpression>, type: LogicGateType)
}

typealias WireID = Substring
typealias LogicGate = (gate: LogicGateType, inputs: Set<WireID>)

extension WireID {
  static func makeID(_ prefix: String, _ bit: Int) -> WireID {
    return "\(prefix)\(String(format: "%02d", bit))"
  }
}

// Define an enum for logic operations
enum LogicGateType: Substring, Hashable {
  case and = "AND"
  case or = "OR"
  case xor = "XOR"
}

private func parseCircuit(_ input: String) -> (
  signals: [WireID: Bool], gates: [WireID: LogicGate]
) {
  // Define the regex patterns
  let inputPattern = #/(?<key>x\d{2}|y\d{2}): (?<value>\d+)/#
  let operationPattern =
    #/(?<input1>\w{3}) (?<gate>AND|OR|XOR) (?<input2>\w{3}) -> (?<output>\w{3})/#

  var signals: [WireID: Bool] = [:]
  var gates: [WireID: LogicGate] = [:]

  // Parse input values
  for match in input.matches(of: inputPattern) {
    let key = match.output.key
    let value = match.output.value

    if let intValue = Int(value) {
      signals[key] = intValue == 1
    }
  }

  // Parse operations
  for match in input.matches(of: operationPattern) {
    let input1 = match.output.input1
    let gate = match.output.gate
    let input2 = match.output.input2
    let output = match.output.output

    if let operation = LogicGateType.init(rawValue: gate) {
      gates[output] = (operation, [input1, input2])
    }
  }

  return (signals, gates)
}
