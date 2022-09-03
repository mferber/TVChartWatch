import SwiftUI

struct ShowList: View {
  let shows: [Show]

  init(_ shows: [Show]) {
    self.shows = shows
  }

  var body: some View {
    List {
      ForEach(shows, id: \.id) { show in
        NavigationLink(
          destination: ShowDisplay(show: show)
            .navigationTitle("Shows")
        ) {
          ShowLabel(show)
        }
      }
    }
    .navigationTitle("Shows")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct ShowLabel: View {
  let show: Show

  init(_ show: Show) {
    self.show = show
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(show.title).font(.headline)
      Text(progressMessage(show: show))
        .font(.footnote)
        .foregroundColor(.accentColor)
    }
  }

  func progressMessage(show: Show) -> String {
    let season = show.seenThru.season
    let episodesWatched = show.seenThru.episodesWatched

    if season < 1 || (season == 1 && episodesWatched == 0) {
      return "Unstarted"
    }

    let seasonMap = show.seasonMap(season: season).filter {
      if case .separator = $0 { return false } else { return true }
    }
    if episodesWatched >= seasonMap.count {
      return "Finished season \(season)"
    }

    var watchedCount = min(episodesWatched, seasonMap.count)
    if case .special = seasonMap[watchedCount - 1] {
      return "Season \(season), special"
    }

    // What's the episode number, skipping over any specials?
    for ep in 1...watchedCount {
      if case .special = seasonMap[ep - 1] {
        watchedCount = watchedCount - 1
      }
    }
    return "Season \(season), episode \(watchedCount)"
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ShowList([
        Show(id: 1, tvmazeId: "1", title: "Diff'rent Strokes", location: "NBC", length: "30 min", seasonMaps: ["..."], seenThru: Marker(season: 0, episodesWatched: 2), favorite: true),
        Show(id: 2, tvmazeId: "2", title: "Doctor Who", location: "BBC", length: "1 hr", seasonMaps: [".....S", ".....S"], seenThru: Marker(season: 1, episodesWatched: 0), favorite: true),
        Show(id: 3, tvmazeId: "3", title: "The Leftovers", location: "Amazon", length: "1 hr", seasonMaps: ["SS+S...+.", ".....S"], seenThru: Marker(season: 1, episodesWatched: 4), favorite: true),
        Show(id: 4, tvmazeId: "4", title: "For All Mankind", location: "Apple TV+", length: "1 hr", seasonMaps: ["SSS.S......"], seenThru: Marker(season: 1, episodesWatched: 20), favorite: true)
      ])
    }
  }
}
