import Foundation

enum APIError: Error, CustomStringConvertible {
  case general(underlyingError: Error? = nil)
  case http(statusCode: Int)

  var description: String {
    switch self {
      case .general(let underlyingError):
        if let err = underlyingError {
          return "Unspecified API error: \(String(describing: err))"
        } else {
          return "Unspecified API error"
        }
      case .http(let statusCode):
        return "API request failed with HTTP error \(statusCode)"
    }
  }
}

public struct API {
  static let baseURL = URL(string: "http://mbp2016.local:8000/")!

  public func fetchShows() async throws -> [Show] {
    let (data, rsp) = try await URLSession.shared.data(from: API.baseURL.appendingPathComponent("shows"))
    guard let hrsp = rsp as? HTTPURLResponse else {
      throw APIError.general()
    }
    guard hrsp.statusCode == 200 else { throw APIError.http(statusCode: hrsp.statusCode)}
    return try JSONDecoder().decode([Show].self, from: data)
  }
}
