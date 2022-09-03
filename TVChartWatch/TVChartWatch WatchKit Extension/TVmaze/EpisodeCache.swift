import Foundation

struct EpisodeCache {
  static var instance = EpisodeCache();

  private var cache = [String: [[Episode]]]()

  private init() { }

  mutating func store(tvmazeShowId: String, episodes: [[Episode]]) {
    cache[tvmazeShowId] = episodes
  }

  func fetch(tvmazeShowId: String) -> [[Episode]]? {
    return cache[tvmazeShowId]
  }
}
