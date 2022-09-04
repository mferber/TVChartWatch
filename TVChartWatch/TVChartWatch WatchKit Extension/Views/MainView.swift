import SwiftUI

struct MainView: View {
  @ObservedObject var shows: Loadable<[Show]>

  @ViewBuilder
  var body: some View {
    switch shows.status {
      case .uninitialized, .inProgress: ProgressView()
      case .success(let shows): ShowList(shows.sortedByTitle())
      case .failure(let err): Text("Error: \(String(describing: err))")
    }
  }
}
