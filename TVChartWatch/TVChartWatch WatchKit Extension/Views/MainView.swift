import SwiftUI

struct MainView: View {
  @ObservedObject var shows: Loadable<[Show]>

  @ViewBuilder
  var body: some View {
    switch shows.status {
      case .uninitialized:
        ProgressView()
      case .inProgress:
        ProgressView()
      case .success(let shows):
        ShowList(shows)
      case .failure(let err):
        Text("Error: \(String(describing: err))")
    }
  }
}
