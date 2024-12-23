import Foundation
import Utils

public class Solution: Day {
  public static var onlySolveExamples: Bool = false

  public static var facitPart1: Int = 1175

  public static func solvePart1(_ input: String) async -> Int {
    let connections = parseConnections(input)

    var computerToComputers: [Computer: Set<Computer>] = [:]

    for connection in connections {
      computerToComputers[connection.0, default: Set<Computer>()].update(with: connection.1)
      computerToComputers[connection.1, default: Set<Computer>()].update(with: connection.0)
    }

    var count = 0

    for (computer, connectedComputers) in computerToComputers {
      if connectedComputers.count < 2 {
        continue
      }

      for connectedComputer in connectedComputers {
        if computer > connectedComputer {
          continue
        }

        count +=
          computerToComputers[connectedComputer]?.filter {
            $0 > connectedComputer && connectedComputers.contains($0)
          }.filter {
            secondaryConnectedComputer in
            [computer, connectedComputer, secondaryConnectedComputer].contains(where: {
              $0.isAdmin()
            })
          }.count ?? 0
      }
    }

    return count
  }

  public static func solvePart2String(_ input: String) async -> String {

    let connections = parseConnections(input)

    var computerToComputers: [Computer: Set<Computer>] = [:]

    for connection in connections {
      computerToComputers[connection.0, default: Set<Computer>()].update(with: connection.1)
      computerToComputers[connection.1, default: Set<Computer>()].update(with: connection.0)
    }

    var groups: [Set<Computer>] = []

    for (computer, connectedComputers) in computerToComputers {
      connectedComputers.filter {
        connectedComputer in 
        computer > connectedComputer
      }.forEach {
        connectedComputer in
        let matchingGroups = groups.enumerated().filter {
          (_, group) in
          group.contains(computer) && group.allSatisfy({
              groupedComputer in 
              computerToComputers[groupedComputer]?.contains(connectedComputer) ?? false
            })
        }

        for (idx,_) in matchingGroups {
          groups[idx].insert(connectedComputer)
        }

        // Add new mini-group
        groups.append(contentsOf: Set(arrayLiteral: [computer, connectedComputer]))
      
      }
    }

    return groups.max {
      (a, b) in
      a.count < b.count
    }?.sorted().joined(separator: ",") ?? ""
  }

}

typealias Computer = Substring

extension Computer {
  func isAdmin() -> Bool {
    self.hasPrefix("t")
  }
}

func parseConnections(_ input: String) -> [(Computer, Computer)] {
  input.matches(of: #/(?<a>[a-z]{2})-(?<b>[a-z]{2})/#).map {
    ($0.output.a, $0.output.b)
  }
}
