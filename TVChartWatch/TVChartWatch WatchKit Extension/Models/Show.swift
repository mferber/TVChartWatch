import Foundation

public struct Show {
  let id: Int
  let tvmazeId: String
  let title: String
  let location: String
  let length: String
  let seasonMaps: [[EpisodeType]]
  let seasonSeparatorIndices: [[Int]]
  let seenThru: Marker
  let favorite: Bool

  public func length(ofSeason season: Int) -> Int {
    return seasonMaps[season - 1].count
  }

  public func isSeen(season: Int, episodeIndex: Int) -> Bool {
    if !seasonMaps.indices.contains(season) ||
        !seasonMaps[season - 1].indices.contains(episodeIndex){
      return false
    }
    if seenThru.season < season {
      return false
    }
    if seenThru.season > season {
      return true
    }
    return seenThru.episodesWatched > episodeIndex
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

extension Array where Element == Show {
  func sortedByTitle() -> [Show] {
    let mapped = self
      .map { show -> (String, Show) in
        let fixedTitle = show.title.replacingOccurrences(
          of: "^(a|an|the)\\b", with: "",
          options: [.regularExpression, .caseInsensitive]
        )
        return (fixedTitle, show)
      }
    let sorted = mapped.sorted { $0.0 < $1.0 }
    let mappedBack = sorted.map { $0.1 }
    return mappedBack
  }
}
