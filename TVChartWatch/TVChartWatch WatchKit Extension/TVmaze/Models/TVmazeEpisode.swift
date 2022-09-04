import Foundation

struct TVmazeEpisode: Decodable {
  let id: Int
  let season: Int
  let number: Int?
  let type: String
  let name: String
  let runtime: Int
  let summary: String?
}
