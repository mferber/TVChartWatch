import Foundation

enum LoadingState<T> {
  case uninitialized
  case inProgress
  case success(_ value: T)
  case failure(_ error: Error)

  mutating func begin() {
    guard case .uninitialized = self else { return }
    self = .inProgress
  }

  mutating func succeed(with value: T) {
    guard case .inProgress = self else { return }
    self = .success(value)
  }

  mutating func fail(with error: Error) {
    guard case .inProgress = self else { return }
    self = .failure(error)
  }
}
