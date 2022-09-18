import SwiftUI

let defaultMarkerHeight: CGFloat = 22
let minMarkerHeight: CGFloat = 8
let maxMarkerHeight: CGFloat = 44

struct ShowDisplay: View {
  @Binding var show: Show
  @State var markerHeight: CGFloat = defaultMarkerHeight

  var body: some View {
    VStack(alignment: .leading) {
      Text(show.title).font(.title3)
      ScrollView(.vertical, showsIndicators: true) {
        VStack(alignment: .leading, spacing: 10) {
          EpisodeChart(show: $show, markerHeight: CGFloat(markerHeight))
        }
      }
    }
    .focusable()
    .digitalCrownRotation(
      $markerHeight,
      from: minMarkerHeight,
      through: maxMarkerHeight,
      by: 0.5,
      sensitivity: .high,
      isContinuous: false,
      isHapticFeedbackEnabled:true
    )
  }
}

private struct EpisodeChart: View {
  @Binding var show: Show
  let markerHeight: CGFloat

  var body: some View {
    VStack(alignment: .leading, spacing: markerHeight / 3) {
      ForEach(1...show.seasonMaps.count, id: \.self) { i in
        Season(show: $show, season: i, markerHeight: markerHeight)
      }
    }
  }
}

private struct Season: View {
  @Binding var show: Show
  let season: Int
  let markerHeight: CGFloat

  var body: some View {
    let seasonMap = show.seasonMaps[season - 1]
    let episodeLabels = seasonMap.map { item -> String? in
      switch item {
        case .special: return nil
        case .numbered(let number): return String(number)
      }
    }
    let separatorIndices = show.seasonSeparatorIndices[season - 1]

    VStack(alignment: .leading, spacing: 4) {
      HStack {
        if show.hasCompleted(season: season) {
          Image(systemName: "checkmark")
        }
        Text("Season \(season)")
      }.font(.footnote)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: markerHeight / 6) {
          ForEach(Array(seasonMap.enumerated()), id: \.offset) { idx, item in
            if separatorIndices.contains(idx) {
              MidseasonSeparator(size: markerHeight * 2 / 3)
            }
            EpisodeButton(
              show: $show,
              season: season,
              episodeIndex: idx,
              item: item,
              text: episodeLabels[idx],
              markerHeight: markerHeight
            )
          }
        }
      }
    }
  }
}

private struct EpisodeButton: View {
  @Binding var show: Show
  let season: Int
  let episodeIndex: Int
  let item: EpisodeType
  let text: String?  // nil indicates an unnumbered special episode
  let markerHeight: CGFloat

  var body: some View {
    NavigationLink(destination: EpisodeView(show: $show, season: season, episodeIndex: episodeIndex)) {
      EpisodeMarker(
        seen: season < show.seenThru.season ||
          (season == show.seenThru.season && episodeIndex + 1 <= show.seenThru.episodesWatched),
        text: text,
        markerHeight: markerHeight
      ).frame(width: markerHeight, height: markerHeight)
    }.buttonStyle(.plain)
  }
}

private struct MidseasonSeparator: View {
  let size: CGFloat

  var body: some View {
    Image(systemName: "plus")
      .foregroundColor(.accentColor)
      .font(.system(size: size, weight: .bold))
  }
}

private struct EpisodeMarker: View {
  let seen: Bool
  let text: String?
  let markerHeight: CGFloat

  var body: some View {
    let markerShape = RoundedRectangle(
      cornerRadius: markerHeight / 3,
      style: .continuous
    )

    ZStack {
      if seen {
        markerShape.fill(Color.accentColor)
      } else {
        markerShape.strokeBorder(Color.accentColor, lineWidth: markerHeight / 20)
      }
      if let text = text {
        Text(text)
          .font(.system(size: markerHeight * 0.6))
          .fontWeight(seen ? .bold : .regular)
          .foregroundColor(seen ? .black : .accentColor)
      } else {
        // special episode: mark with a star
        Image(systemName: "star.fill")
          .font(.system(size: markerHeight * 0.6))
          .foregroundColor(seen ? .black : .accentColor)
      }
    }
  }
}

struct ShowDisplay_Previews: PreviewProvider {
  static var previews: some View {
    let show = CodableShow(
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
    ).asShow()
    
    ShowDisplay(show: .constant(show))
  }
}
