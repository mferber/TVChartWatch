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
