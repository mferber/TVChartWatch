import SwiftUI

let missingSynopsisText = "No episode synopsis is currently available."

struct EpisodeView: View {
  @Binding var show: Show
  let season: Int
  let episodeIndex: Int

  @StateObject private var episodeInfo = Loadable<Episode>()

  var body: some View {
    let watched = show.isSeen(season: season, episodeIndex: episodeIndex)

    Group {
      switch episodeInfo.status {
        case .uninitialized, .inProgress: ProgressView()
        case .success(let episode): EpisodeDetails(show: $show, episode: episode, watched: watched)
        case .failure(let error): displayError(error)
      }
    }
    .navigationTitle(show.title)
    .task {
      await episodeInfo.load {
        let seasonIndex = season - 1
        let episodes = try await fetchEpisodesWithCache(show: show)
        if !episodes.indices.contains(seasonIndex) || !episodes[seasonIndex].indices.contains(episodeIndex) {
          throw TVmazeError.episodeOutOfRange
        }
        return episodes[seasonIndex][episodeIndex]
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

  func displayError(_ error: Error) -> some View {
    switch error {
      case TVmazeError.episodeOutOfRange:
        return AnyView(
          Text("No information is currently available for this episode.")
            .font(.body)
            .italic()
          )
      default:
        return AnyView(
          VStack(alignment: .leading, spacing: 20) {
            Text("Something went wrong").font(.body).italic()
            Text(String(describing: error)).font(.footnote)
          }
        )
    }
  }
}

private struct EpisodeDetails: View {
  @Binding var show: Show
  let episode: Episode
  let watched: Bool

  var body: some View {
    ScrollView(.vertical) {
      VStack(alignment: .leading, spacing: 10) {
        VStack(alignment: .leading) {
          Text(episode.title).font(.title3)
          Text(episodeDescriptor).font(.footnote)
        }

        Button(action: markLastWatched) {
          HStack {
            if watched {
              Image(systemName: "checkmark")
            }
            Text("Mark last watched")
          }
        }

        Group {
          if let synopsis = episode.synopsis {
            Text(synopsis)
          } else {
            Text(missingSynopsisText).italic()
          }
        }.font(.caption2)
      }
    }
  }

  var episodeDescriptor: String {
    let epId: String
    if let number = episode.number {
      epId = "E\(number)"
    } else {
      epId = " Special"
    }

    let epLength: String
    if let length = episode.length {
      epLength = "(\(length))"
    } else {
      epLength = ""
    }

    return "S\(episode.season)\(epId) \(epLength)"
  }

  func markLastWatched() {
    Task {
      do {
        let marker = Marker(season: episode.season, episodesWatched: episode.episodeIndex + 1)
        let updated = try await API().update(seenThru: marker, for: show)
        await MainActor.run {
          show = updated
        }
      } catch {
        print(error)
      }
    }
  }
}
