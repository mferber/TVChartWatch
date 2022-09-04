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

  public func length(ofSeason season: Int) -> Int {
    let chars = seasonMaps[season - 1]
    let result = chars.reduce(into: 0) { sum, ch in
      if (ch == "S" || ch == ".") {
        sum = sum + 1
      }
    }
    return result
  }

  public func hasCompleted(season: Int) -> Bool {
    if seenThru.season < season {
      return false
    }
    if seenThru.season > season {
      return true
    }
    return seenThru.episodesWatched >= length(ofSeason: season)
  }
}
