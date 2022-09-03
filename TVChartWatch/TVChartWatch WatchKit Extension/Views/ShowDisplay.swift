import SwiftUI

// TODO: make this @State and control with digital crown
private let markerHeight: CGFloat = 22

struct ShowDisplay: View {
  let show: Show

  var body: some View {
    VStack(alignment: .leading) {
      Text(show.title).font(.headline)
      ScrollView(.vertical, showsIndicators: true) {
        VStack(alignment: .leading, spacing: 10) {
          EpisodeChart(show: show)
        }
      }
    }
  }
}

private struct EpisodeChart: View {
  let show: Show

  var body: some View {
    VStack(alignment: .leading, spacing: markerHeight / 3) {
      ForEach(1...show.seasonMaps.count, id: \.self) { i in
        Season(show: show, season: i)
      }
    }
  }
}

private struct Season: View {
  let show: Show
  let season: Int

  var body: some View {
    let seasonMap = show.seasonMap(season: season)
    let episodeTexts = seasonMap.map { item -> String in
      switch item {
        case .special: return "S"
        case .sequential(let number): return String(number)
        default: return ""
      }
    }

    VStack(alignment: .leading, spacing: 4) {
      Text("Season \(season)").font(.footnote)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: markerHeight / 6) {
          ForEach(Array(seasonMap.enumerated()), id: \.offset) { i, item in
            if case .separator = item {
              MidseasonSeparator()
            } else {
              EpisodeButton(
                show: show,
                season: season,
                episodeIndex: i,
                item: item,
                text: episodeTexts[i]
              )
            }
          }
        }
      }
    }
  }
}

private struct EpisodeButton: View {
  let show: Show
  let season: Int
  let episodeIndex: Int
  let item: SeasonMapItem
  let text: String

  var body: some View {
    NavigationLink(destination: EpisodeDetails(text: "\(show.title) \(text)")) {
      EpisodeMarker(
        seen: season < show.seenThru.season ||
          (season == show.seenThru.season && episodeIndex + 1 <= show.seenThru.episodesWatched),
        text: text
      ).frame(width: markerHeight, height: markerHeight)
    }.buttonStyle(.plain)
  }
}

private struct MidseasonSeparator: View {
  var body: some View {
    Image(systemName: "plus")
      .foregroundColor(.accentColor)
      .font(.system(size: markerHeight * 2 / 3, weight: .bold))
  }
}

private struct EpisodeMarker: View {
  let seen: Bool
  let text: String

  var body: some View {
    ZStack {
      if seen {
        Circle().fill(Color.accentColor)
      } else {
        Circle().strokeBorder(Color.accentColor, lineWidth: markerHeight / 10)
      }
      Text(text)
        .font(.system(size: markerHeight * 0.6))
        .bold()
        .foregroundColor(seen ? .black : .white)
    }
  }
}

struct ShowDisplay_Previews: PreviewProvider {
  static var previews: some View {
    let show = Show(
      id: 2,
      tvmazeId: "618",
      title:"Battlestar Galactica",
      location: "Netflix",
      length: "1 hour",
      seasonMaps: [
        "S.+....",
        ".....",
        "...........................",
        "........",
        "........",
        "..........",
        "..........",
        "..........",
        "..........",
        "..........S",
        "..........",
        "..........S",
        ".........."
      ],
      seenThru: Marker(
        season: 4,
        episodesWatched: 5
      ),
      favorite: true
    );
    ShowDisplay(show: show)
  }
}
