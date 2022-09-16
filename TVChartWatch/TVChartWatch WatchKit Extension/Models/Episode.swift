import Foundation

struct Episode {
  let tvmazeId: String
  let season: Int  // 1-based
  let episodeIndex: Int  // 0-based
  let number: Int?  // official episode number; nil for specials
  let title: String
  let length: String?
  let synopsis: String?
}
