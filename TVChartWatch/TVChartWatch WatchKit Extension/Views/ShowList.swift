import SwiftUI

struct ShowList: View {
  let shows: ShowsLoadingState

  @ViewBuilder
  var body: some View {
    switch shows {
      case .uninitialized:
        ProgressView()
      case .inProgress:
        ProgressView()
      case .success(let shows):
        Text("Found \(shows.count) show(s)")
      case .failure(let err):
        Text("Error: \(String(describing: err))")
    }
  }
}

