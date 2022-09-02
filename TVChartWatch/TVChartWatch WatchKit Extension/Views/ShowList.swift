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
          destination: Text(show.title)
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
    let progress = show.seenThru
    if progress.season <= 1 && progress.episodesWatched == 0 {
      return "Unstarted"
    }
    let epMessage = progress.episodesWatched == 0 ? "unstarted" : "ep. \(progress.episodesWatched)"
    return "Season \(progress.season), \(epMessage)"
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ShowList([
        Show(id: 1, tvmazeId: "1", title: "Diff'rent Strokes", location: "NBC", length: "30 min", seasonMaps: ["..."], seenThru: Marker(season: 1, episodesWatched: 2), favorite: true),
        Show(id: 2, tvmazeId: "2", title: "Doctor Who", location: "BBC", length: "1 hr", seasonMaps: [".....S", ".....S"], seenThru: Marker(season: 2, episodesWatched: 3), favorite: true)
      ])
    }
  }
}
