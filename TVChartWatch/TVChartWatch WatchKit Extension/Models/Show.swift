import Foundation

public struct Show: Decodable {
  public enum EpisodeInfo {
    case special
    case sequential(Int)
  }

  let id: Int
  let tvmazeId: String
  let title: String
  let location: String
  let length: String
  let seasonMaps: [String]
  let seenThru: Marker
  let favorite: Bool

  public func seasonMap(season: Int) -> [EpisodeInfo] {
    var result = [EpisodeInfo]()
    let strMap = seasonMaps[season - 1]
    var epCounter = 0
    for ch in strMap {
      switch ch {
        case ".":
          epCounter = epCounter + 1
          result.append(.sequential(epCounter))
        case "S":
          result.append(.special)
        default:
          // + divider or unrecognized char doesn't count as an episode
          break
      }
    }
    return result
  }
}
