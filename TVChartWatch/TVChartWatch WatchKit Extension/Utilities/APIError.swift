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
