import SwiftUI

struct ContentView: View {
  var body: some View {
    Text("Hello, World!")
      .padding()
      .task {
        do {
          let allShows = try await API().fetchShows()
        } catch {
          print(error)
        }
      }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
