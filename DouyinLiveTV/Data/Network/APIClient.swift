import Foundation

public enum APIError: Error, Equatable {
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case unauthorized
    case forbidden
    case serverError(Int)

    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError, .networkError):
            return true // We can't compare associated values, but equatable conformance needed
        case (.invalidResponse, .invalidResponse):
            return true
        case (.decodingError, .decodingError):
            return true // Can't compare associated errors
        case (.unauthorized, .unauthorized):
            return true
        case (.forbidden, .forbidden):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}

extension APIError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized - authentication required"
        case .forbidden:
            return "Forbidden - access denied"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        }
    }
}

public class APIClient: Sendable {
    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func request<T: Decodable>(_ endpoint: Endpoint<T>) async throws -> T {
        var urlComponents = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)

        // Add query parameters if any
        if let parameters = endpoint.parameters, !parameters.isEmpty {
            urlComponents?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }

        guard let url = urlComponents?.url else {
            throw APIError.invalidResponse
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue

        // Add headers if any
        endpoint.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Add body if any
        urlRequest.httpBody = endpoint.body

        do {
            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    return decodedResponse
                } catch let decodingError {
                    throw APIError.decodingError(decodingError)
                }
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 500...:
                throw APIError.serverError(httpResponse.statusCode)
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
