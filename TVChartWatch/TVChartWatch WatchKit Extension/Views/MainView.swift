import SwiftUI

struct MainView: View {
  let shows: ShowsLoadingState

  @ViewBuilder
  var body: some View {
    switch shows {
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
