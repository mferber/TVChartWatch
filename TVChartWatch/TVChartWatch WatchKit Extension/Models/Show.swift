import Foundation

public struct Show: Decodable {
  let id: Int
  let tvmazeId: String
  let title: String
  let location: String
  let length: String
  let seasonMaps: [String]
  let seenThru: Marker
  let favorite: Bool

  public func seasonMap(season: Int) -> [SeasonMapItem] {
    var result = [SeasonMapItem]()
    let strMap = seasonMaps[season - 1]
    var epCounter = 0
    for ch in strMap {
      switch ch {
        case ".":
          epCounter = epCounter + 1
          result.append(.sequential(epCounter))
        case "S":
          result.append(.special)
        case "+":
          result.append(.separator)
        default:
          break
      }
    }
    return result
  }
}
