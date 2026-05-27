import Foundation

enum APIClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int, message: String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "We could not reach the server.")
        case .invalidResponse:
            return String(localized: "The server response was not valid.")
        case let .requestFailed(statusCode, message):
            return Self.userMessage(statusCode: statusCode, message: message)
        case let .decodingFailed(message):
            return message
        }
    }

    var isUnauthorized: Bool {
        if case let .requestFailed(statusCode, _) = self {
            return statusCode == 401
        }

        return false
    }

    private static func userMessage(statusCode: Int, message: String) -> String {
        switch statusCode {
        case 400:
            return message
        case 401:
            return String(localized: "Your session has expired. Please log in again.")
        case 403:
            return message
        case 404:
            return message
        case 500...599:
            return String(localized: "The server is having trouble right now. Please try again shortly.")
        default:
            return message.isEmpty ? String(localized: "Something went wrong. Please try again.") : message
        }
    }
}

struct APIClient {
    let baseURL: URL
    let session: URLSession
    let decoder: JSONDecoder
    let encoder: JSONEncoder

    init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = APIClient.defaultDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func request<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response {
        let request = try makeURLRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        try validate(response: response, data: data)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIClientError.decodingFailed(String(localized: "The server response could not be read."))
        }
    }

    func request(_ endpoint: APIEndpoint) async throws {
        let request = try makeURLRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        try validate(response: response, data: data)
    }

    func encodeBody<Body: Encodable>(_ body: Body) throws -> Data {
        try encoder.encode(body)
    }

    private static func defaultDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: value) {
                return date
            }

            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(value)"
            )
        }
        return decoder
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = errorMessage(from: data) ?? "Unknown server error"
            throw APIClientError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }
    }

    private func errorMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }

        if
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let error = object["error"] as? String
        {
            if
                let details = object["details"] as? [[String: Any]],
                let firstMessage = details.compactMap({ $0["message"] as? String }).first
            {
                return firstMessage
            }

            return error
        }

        return String(data: data, encoding: .utf8)
    }

    private func makeURLRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}
