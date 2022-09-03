import SwiftUI

// TODO: make this @State and control with digital crown
private let markerHeight: CGFloat = 24

struct ShowDisplay: View {
  let show: Show

  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack(alignment: .leading, spacing: 10) {
        Text(show.title).font(.headline)
        EpisodeChart(show: show)
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
              EpisodeMarker()
            }
          }
        }
      }
    }
  }
}

private struct EpisodeMarker: View {
  var body: some View {
    Circle()
      .fill(Color.accentColor)
      .frame(width: markerHeight, height: markerHeight)
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
        episodesWatched: 8
      ),
      favorite: true
    );
    ShowDisplay(show: show)
  }
}
