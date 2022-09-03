import SwiftUI

struct ContentView: View {
  @StateObject var allShows = Loadable<[Show]>()

  var body: some View {
    MainView(shows: allShows)
      .task {
        await allShows.load {
          try await API().fetchShows()
        }
      }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
