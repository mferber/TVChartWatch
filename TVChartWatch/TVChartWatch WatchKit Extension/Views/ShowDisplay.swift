import SwiftUI

// TODO: make this @State and control with digital crown
private let markerHeight: CGFloat = 24

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

    VStack(alignment: .leading, spacing: 4) {
      Text("Season \(season)").font(.footnote)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: markerHeight / 6) {
          ForEach(Array(seasonMap.enumerated()), id: \.offset) { i, item in
            if case .separator = item {
              Image(systemName: "plus")
                .foregroundColor(.accentColor)
                .frame(width: markerHeight / 2, height: markerHeight / 2)
            } else {
              EpisodeMarker(
                seen: season < show.seenThru.season ||
                  (season == show.seenThru.season && i + 1 <= show.seenThru.episodesWatched)
              ).frame(width: markerHeight, height: markerHeight)
            }
          }
        }
      }
    }
  }
}

private struct EpisodeMarker: View {
  let seen: Bool

  var body: some View {
    if seen {
      Circle()
        .fill(Color.accentColor)
    } else {
      Circle().strokeBorder(Color.accentColor, lineWidth: markerHeight / 10)
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
