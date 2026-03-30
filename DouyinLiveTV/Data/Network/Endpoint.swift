import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public struct Endpoint<Response: Decodable>: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let parameters: [String: String]?
    public var headers: [String: String]?
    public let body: Data?
    public let baseURL: URL

    public init(
        baseURL: URL,
        path: String,
        method: HTTPMethod,
        parameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.body = body
    }
}
