import Foundation

enum APIError: LocalizedError {
  case general
  case http(statusCode: Int)

  var errorDescription: String? {
    switch self {
      case .general: return "Unspecified API error"
      case .http(let statusCode): return "API request failed with HTTP error \(statusCode)"
    }
  }
}

public struct API {
  static let baseURL = URL(string: "http://mbp2016.local:8000/")!

  public func fetchShows() async throws -> [Show] {
    let (data, rsp) = try await URLSession.shared.data(from: API.baseURL.appendingPathComponent("shows"))
    guard let hrsp = rsp as? HTTPURLResponse else {
      throw APIError.general
    }
    guard hrsp.statusCode == 200 else { throw APIError.http(statusCode: hrsp.statusCode)}

    print(String(data: data, encoding: .utf8)!)
    return try JSONDecoder().decode([Show].self, from: data)
  }
}
