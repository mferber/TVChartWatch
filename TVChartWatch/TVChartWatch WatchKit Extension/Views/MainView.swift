import SwiftUI
import Combine

struct MainView: View {
  @StateObject var mainViewModel = MainViewModel()

  let source: Loadable<[Show]>

  @ViewBuilder
  var body: some View {
    VStack {
      if let showsBinding = Binding($mainViewModel.shows) {  // TODO: make sure this preserves the 2-way binding!
        ShowList(shows: showsBinding)
      } else if let error = mainViewModel.error {
        Text("Error: \(String(describing: error))").font(.footnote)
      } else {
        ProgressView()
      }
    }.onAppear {
      mainViewModel.drive(from: source)
    }
  }
}

class MainViewModel: ObservableObject {

  // TODO this is very kludgey, is there a better way?
  var hasSource = false

  @Published var shows: [Show]? {
    didSet { print("shows updated") }
  }
  @Published var error: Error?

  var cancellables: Set<AnyCancellable> = []

  func drive(from source: Loadable<[Show]>) {
    if !hasSource {
      source.$status.sink(receiveValue: { [weak self] status in
        guard let sself = self else { return }

        switch status {
          case .success(let value):
            sself.adopt(receivedShows: value)
          case .failure(let error):
            sself.error = error
          default:
            break
        }
      }).store(in: &cancellables)
    }
    hasSource = true
  }

  func adopt(receivedShows: [Show]) {
    print("adopting from Loadable")
    shows = receivedShows.filter { $0.favorite }.sortedByTitle()
  }
}
