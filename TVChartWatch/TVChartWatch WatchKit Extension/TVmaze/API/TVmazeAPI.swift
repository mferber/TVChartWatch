import Foundation

struct TVmazeAPI {
  private static let baseURL = URL(string: "https://api.tvmaze.com/")!

  func fetchEpisodes(show: Show) async throws -> [[Episode]] {
    let url = URL(
      string: "shows/\(encodedTvmazeId(show: show))/episodes?specials=1",
      relativeTo: TVmazeAPI.baseURL
    )!
    let (data, rsp) = try await URLSession.shared.data(from: url)

    guard let hrsp = rsp as? HTTPURLResponse else {
      throw APIError.general()
    }
    guard hrsp.statusCode == 200 else {
      throw APIError.http(statusCode: hrsp.statusCode)
    }
    let rawEpisodes = try JSONDecoder().decode([TVmazeEpisode].self, from: data)
    return compileSeasonLists(tvmazeEpisodes: rawEpisodes)
  }

  // TODO: move out of TVmazeAPI?
  private func compileSeasonLists(tvmazeEpisodes: [TVmazeEpisode]) -> [[Episode]] {
    var result = [[Episode]]()
    for ep in tvmazeEpisodes {
      guard ep.type != "insignificant_special" else { continue }

      while result.count <= ep.season {
        result.append([])
      }
      let seasonIndex = ep.season - 1
      result[seasonIndex].append(
        constructEpisode(tvmazeEpisode: ep, episodeIndex: result[seasonIndex].count)
      )
    }
    return result
  }

  private func constructEpisode(tvmazeEpisode: TVmazeEpisode, episodeIndex: Int) -> Episode {
    let length: String?
    if let runtime = tvmazeEpisode.runtime {
      length = "\(runtime) min."
    } else {
      length = nil
    }

    return Episode(
      tvmazeId: String(tvmazeEpisode.id),
      season: tvmazeEpisode.season,
      episodeIndex: episodeIndex,
      number: tvmazeEpisode.number,
      title: tvmazeEpisode.name,
      length: length,
      synopsis: sanitize(synopsis: tvmazeEpisode.summary)
    )
  }

  private func sanitize(synopsis: String?) -> String? {
    guard let synopsis = synopsis else { return nil }
    return synopsis.replacingOccurrences(of: "<.*?>", with: "", options: .regularExpression)
  }

  private func encodedTvmazeId(show: Show) -> String {
    return show.tvmazeId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
  }
}
