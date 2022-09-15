import SwiftUI

public class Loadable<T>: ObservableObject {
  public enum LoadStatus: CustomStringConvertible {
    case uninitialized
    case inProgress
    case success(_ value: T)
    case failure(_ error: Error)

    public var description: String {
      switch self {
        case .uninitialized: return "uninitialized"
        case .inProgress: return "inProgress"
        case .success: return "success"
        case .failure: return "failure"
      }
    }
  }

  @Published public private(set) var status = LoadStatus.uninitialized

  func load(loader: @escaping () async throws -> T) async {
    assert({
      switch status {
        case .uninitialized: return true
        default: return false
      }
    }(), "Loadable.load() called multiple times on same instance")

//    print("-> inProgress (\(T.self))")
    status = .inProgress

    do {
      let result = try await loader()
//      print("-> succeed (\(T.self))")
      succeed(with: result)
    } catch {
//      print("-> fail (\(T.self))")
      fail(with: error)
    }
  }

  private func succeed(with value: T) {
    status = .success(value)
  }

  private func fail(with error: Error) {
    status = .failure(error)
    print("Error loading resource: \(error)")
  }
}
