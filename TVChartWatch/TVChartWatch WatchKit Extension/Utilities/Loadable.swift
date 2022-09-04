import SwiftUI

public class Loadable<T>: ObservableObject {
  public enum LoadStatus {
    case uninitialized
    case inProgress
    case success(_ value: T)
    case failure(_ error: Error)
  }

  @Published public private(set) var status = LoadStatus.uninitialized

  func load(loader: @escaping () async throws -> T) async {
    assert({
      switch status {
        case .uninitialized: return true
        default: return false
      }
    }(), "Loadable.load() called multiple times on same instance")

    status = .inProgress

    do {
      let result = try await loader()
      succeed(with: result)
    } catch {
      fail(with: error)
    }
  }

  private func succeed(with value: T) {
    status = .success(value)
  }

  private func fail(with error: Error) {
    status = .failure(error)
  }
}
