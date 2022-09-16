import SwiftUI

struct ShowList: View {
  @Binding var shows: [Show] {
    didSet { print("ShowList.shows updated") }
  }

  var body: some View {
    List {
      ForEach($shows, id: \.id) { $show in
        NavigationLink(
          destination: ShowDisplay(show: $show)
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
      progressMessage(show: show)
        .font(.footnote)
        .foregroundColor(.accentColor)
    }
  }

  func progressMessage(show: Show) -> some View {
    let season = show.seenThru.season
    let episodesWatched = show.seenThru.episodesWatched

    if season < 1 || (season == 1 && episodesWatched == 0) {
      return AnyView(
        Text("Unstarted")
      )
    }

    let seasonLength = show.length(ofSeason: season)
    if episodesWatched >= seasonLength {
      if season >= show.seasonMaps.count {
        return AnyView(
          HStack {
            Image(systemName: "checkmark.circle.fill")
            Text("Finished")
          }
        )
      }

      return AnyView(
        Text("Finished season \(season)")
      )
    }

    return AnyView(
      HStack {
        Text("Season \(season)")
        Spacer()
        Text("\(seasonLength - episodesWatched) left")
      }
    )
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    let shows = [
      CodableShow(id: 1, tvmazeId: "1", title: "Diff'rent Strokes", location: "NBC", length: "30 min", seasonMaps: ["..."], seenThru: Marker(season: 0, episodesWatched: 2), favorite: true),
      CodableShow(id: 2, tvmazeId: "2", title: "Doctor Who", location: "BBC", length: "1 hr", seasonMaps: [".....S", ".....S"], seenThru: Marker(season: 1, episodesWatched: 0), favorite: true),
      CodableShow(id: 3, tvmazeId: "3", title: "The Leftovers", location: "Amazon", length: "1 hr", seasonMaps: ["SS+S...+.", ".....S"], seenThru: Marker(season: 1, episodesWatched: 4), favorite: true),
      CodableShow(id: 4, tvmazeId: "4", title: "For All Mankind", location: "Apple TV+", length: "1 hr", seasonMaps: ["SSS.S......"], seenThru: Marker(season: 1, episodesWatched: 20), favorite: true)
    ].map { $0.asShow() }

    NavigationView {
      ShowList(shows: .constant(shows))
    }
  }
}
