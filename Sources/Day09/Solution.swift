import Foundation
import Utils

func parseFragmentationMap(_ input: String) -> [Int] {
  input.compactMap { char in Int(String(char)) }
}
public struct Solution: Day {
  public static var onlySolveExamples: Bool {
    return false
  }

  public static func solvePart1(_ input: String) async -> Int {
    let fragmentSizes = parseFragmentationMap(input)

    var fragmentationLayout: [Int?] = []
    for i in 0..<fragmentSizes.count {
      if i % 2 == 0 {
        // Initialize file blocks with file ID
        let fileID = i / 2
        fragmentationLayout += Array(repeating: fileID, count: fragmentSizes[i])
      } else {
        // Initialize gap blocks
        fragmentationLayout += Array(repeating: nil, count: fragmentSizes[i])
      }
    }

    // Move blocks one at a time from end to first gap
    var rightCursor = fragmentationLayout.count - 1
    var leftCursor = 0

    while rightCursor > leftCursor {
      if fragmentationLayout[leftCursor] != nil {
        leftCursor += 1
        continue
      }

      if fragmentationLayout[rightCursor] == nil {
        rightCursor -= 1
        continue
      }

      // Move file block to gap
      fragmentationLayout[leftCursor] = fragmentationLayout[rightCursor]
      fragmentationLayout[rightCursor] = nil
      leftCursor += 1
      rightCursor -= 1
    }

    return fragmentationLayout.enumerated().compactMap {
      (position, fileID) in
      fileID.map { position * $0 }
    }.reduce(0, +)
  }

  struct FileMetadata: Indexable {
    var key: Int {
      fileID
    }

    let fileID: Int
    let startPosition: Int
    let size: Int
  }

  public static func solvePart2(_ input: String) async -> Int {
    let fragmentSizes = parseFragmentationMap(input)

    let fileMetadata: MultiIndexList<FileMetadata> =
      MultiIndexList()

    var offset = 0
    for i in 0..<fragmentSizes.count {
      if i % 2 == 0 {
        let fileID = i / 2
        fileMetadata.add(FileMetadata(fileID: fileID, startPosition: offset, size: fragmentSizes[i]))
      }

      offset += fragmentSizes[i]
    }

    // Move whole files to leftmost suitable gap
    for file in fileMetadata.listItems().reversed().dropLast() {

      let (fileID, fileStart, fileSize) = (file.fileID, file.startPosition, file.size)

      let targetPosition =
        zip(fileMetadata.listItems()[0..<fileMetadata.listItems().count - 1], fileMetadata.listItems()[1...])
        .first { (element) in
          let (a, b) = element
          let (_, aStart, aSize) = (a.fileID, a.startPosition, a.size)
          let (_, bStart, _) = (b.fileID, b.startPosition, b.size)

          let freeSpaceBetweenFiles = bStart - (aStart + aSize)
          return fileStart >= aStart + aSize && fileSize <= freeSpaceBetweenFiles
        }

      if let targetPosition = targetPosition {
        let ((a, _)) = targetPosition
        let (_, targetStart, targetSize) = (a.fileID, a.startPosition, a.size)

        fileMetadata.remove(forKey: fileID)
        fileMetadata.insert(
          FileMetadata(
            fileID: fileID,
            startPosition: targetStart + targetSize,
            size: fileSize
          ), at: fileMetadata.index(forKey: a.key) + 1)
      }
    }

    return fileMetadata.listItems().reduce(0) { (acc, file) in
      let (fileID, startPosition, size) = (file.fileID, file.startPosition, file.size)
      // startPosition * fileID + (startPosition + 1) * fileID + ... + (startPosition + size - 1) * fileID

      let innerSum = (startPosition + startPosition + (size - 1)) * size / 2
      let totalSum = fileID * innerSum

      return acc + totalSum
    }
  }
}

// Define a protocol for items that can be indexed
protocol Indexable {
  var key: Int { get }
}

// MultiIndexList Class
class MultiIndexList<T: Indexable> {
  private var items: [T] = []  // Ordered storage
  private var indexByKey: [Int] = []  // Key -> Index mapping for O(1) access

  init() {
    indexByKey = Array(repeating: -1, count: 0)
  }

  // Add an item to the list
  func add(_ item: T) {
    guard item.key >= 0 && item.key < indexByKey.count && indexByKey[item.key] == -1 else {
      print("Duplicate or invalid key detected: \(item.key)")
      return
    }
    indexByKey[item.key] = items.count
    items.append(item)
  }

  func insert(_ item: T, at index: Int) {
    guard item.key >= 0 && item.key < indexByKey.count && indexByKey[item.key] == -1 else {
      print("Duplicate or invalid key detected: \(item.key)")
      return
    }
    indexByKey[item.key] = index
    items.insert(item, at: index)

    // Update indices in the array
    for i in index + 1..<items.count {
      indexByKey[items[i].key] = i
    }
  }

  // Access item by key
  func item(forKey key: Int) -> T? {
    guard let key = key as? Int, key >= 0 && key < indexByKey.count, indexByKey[key] != -1 else { return nil }
    return items[indexByKey[key]]
  }

  // Remove an item by key
  func remove(forKey key: Int) {
    guard let key = key as? Int, key >= 0 && key < indexByKey.count, indexByKey[key] != -1 else { return }

    // Remove the item
    let index = indexByKey[key]
    items.remove(at: index)
    indexByKey[key] = -1

    // Update indices in the array
    for i in index..<items.count {
      indexByKey[items[i].key] = i
    }
  }

  func index(forKey key: Int) -> Int {
    guard let key = key as? Int, key >= 0 && key < indexByKey.count else { fatalError("Invalid key") }
    return indexByKey[key]
  }

  // List all items
  func listItems() -> [T] {
    return items
  }
}
