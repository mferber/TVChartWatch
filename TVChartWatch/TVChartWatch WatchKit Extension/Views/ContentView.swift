import SwiftUI

typealias ShowsLoadingState = LoadingState<[Show]>

struct ContentView: View {
  @State var allShows = ShowsLoadingState.uninitialized

  var body: some View {
    ShowList(shows: allShows)
      .padding()
      .task {
        do {
          allShows.begin()
          let shows = try await API().fetchShows()
          allShows.succeed(with: shows)
        } catch {
          allShows.fail(with: error)
        }
      }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
