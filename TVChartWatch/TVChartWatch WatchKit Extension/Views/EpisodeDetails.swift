import SwiftUI

let missingSynopsisText = "No episode synopsis is currently available."

struct EpisodeView: View {
  let show: Show
  let season: Int
  let episodeIndex: Int

  @StateObject private var episodeInfo = Loadable<Episode>()

  var body: some View {
    Group {
      switch episodeInfo.status {
        case .uninitialized, .inProgress: ProgressView()

        // TODO: include season in Episode?
        case .success(let episode): EpisodeDetails(episode: episode, season: season)
        case .failure(let error): Text(String(describing: error))
      }
    }
    .navigationTitle(show.title)
    .task {
      await episodeInfo.load {
        let episodes = try await fetchEpisodesWithCache(show: show)
        if !episodes.indices.contains(season - 1) || !episodes[season - 1].indices.contains(episodeIndex) {
          throw TVmazeError.episodeOutOfRange
        }
        return episodes[season - 1][episodeIndex]
      }
    }
  }

  func fetchEpisodesWithCache(show: Show) async throws -> [[Episode]] {
    var episodes = EpisodeCache.instance.fetch(tvmazeShowId: show.tvmazeId)
    if episodes == nil {
      episodes = try await TVmazeAPI().fetchEpisodes(show: show)
      guard let episodes = episodes else { throw TVmazeError.showNotFound }
      EpisodeCache.instance.store(tvmazeShowId: show.tvmazeId, episodes: episodes)
    }
    return episodes!
  }
}

private struct EpisodeDetails: View {
  let episode: Episode
  let season: Int

  var body: some View {
    ScrollView(.vertical) {
      VStack(alignment: .leading) {
        Text(episode.title).font(.headline)
        Text(episodeDescriptor).font(.subheadline)
        Button("Mark watched", action: {})

        if let synopsis = episode.synopsis {
          Text(synopsis)
        } else {
          Text(missingSynopsisText).italic()
        }
      }
    }
  }

  var episodeDescriptor: String {
    let epId: String
    if let number = episode.number {
      epId = "episode \(number)"
    } else {
      epId = "special"
    }
    return "Season \(season), \(epId)"
  }
}
