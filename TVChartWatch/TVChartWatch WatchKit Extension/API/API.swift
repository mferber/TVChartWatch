import Foundation

public struct API {
  static let baseURL = URL(string: "http://mbp2012.local:8000/")!

  public func fetchShows() async throws -> [Show] {
    let url = URL(string: "shows", relativeTo: API.baseURL)!
    let (data, rsp) = try await URLSession.shared.data(from: url)
    guard let hrsp = rsp as? HTTPURLResponse else {
      throw APIError.general()
    }
    guard hrsp.statusCode == 200 else { throw APIError.http(statusCode: hrsp.statusCode)}
    return try JSONDecoder().decode([Show].self, from: data)
  }
}
