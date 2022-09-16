import Foundation

public struct API {
  static let baseURL = URL(string: "http://mbp2016.local:8000/")!

  public func fetchShows() async throws -> [Show] {
    let url = URL(string: "shows", relativeTo: API.baseURL)!
    let (data, rsp) = try await URLSession.shared.data(from: url)
    guard let hrsp = rsp as? HTTPURLResponse else {
      throw APIError.general()
    }
    guard hrsp.statusCode == 200 else { throw APIError.http(statusCode: hrsp.statusCode)}
    return try JSONDecoder().decode([CodableShow].self, from: data).map { $0.asShow() }
  }
}

struct CodableShow: Decodable {
  let id: Int
  let tvmazeId: String
  let title: String
  let location: String
  let length: String
  let seasonMaps: [String]
  let seenThru: Marker
  let favorite: Bool

  func asShow() -> Show {
    var convertedSeasonMaps: [[EpisodeType]] = []
    var convertedSeasonSeparatorIndices: [[Int]] = []
    for mapStr in seasonMaps {
      let converted = convertSeasonMap(mapStr)
      convertedSeasonMaps.append(converted.seasonMap)
      convertedSeasonSeparatorIndices.append(converted.seasonSeparatorIndices)
    }

    return Show(
      id: id,
      tvmazeId: tvmazeId,
      title: title,
      location: location,
      length: length,
      seasonMaps: convertedSeasonMaps,
      seasonSeparatorIndices: convertedSeasonSeparatorIndices,
      favorite: favorite,
      seenThru: seenThru
    )
  }

  func convertSeasonMap(_ mapStr: String) -> (seasonMap: [EpisodeType], seasonSeparatorIndices: [Int]) {
    var resultEpisodes: [EpisodeType] = []
    var resultSeasonSeparatorIndices: [Int] = []

    var nextEpisodeNumber = 1
    for char in mapStr {
      switch char {
        case ".":
          resultEpisodes.append(.numbered(nextEpisodeNumber))
          nextEpisodeNumber = nextEpisodeNumber + 1
        case "S":
          resultEpisodes.append(.special)
        case "+":
          resultSeasonSeparatorIndices.append(resultEpisodes.count)
        default:
          break
      }
    }
    return (seasonMap: resultEpisodes, seasonSeparatorIndices: resultSeasonSeparatorIndices)
  }
}
