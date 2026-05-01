import Foundation

struct APIAuthService: AuthServicing {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func register(draft: RegistrationDraft) async throws {
        let requestBody = try client.encodeBody(RegisterRequest(draft: draft))
        let endpoint = APIEndpoint(
            path: "/auth/register",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )

        try await client.request(endpoint)
    }

    func signIn(email: String, password: String) async throws -> AuthSession {
        let requestBody = try client.encodeBody(LoginRequest(email: email, password: password))
        let endpoint = APIEndpoint(
            path: "/auth/login",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )

        let response: AuthResponse = try await client.request(endpoint)
        return response.toDomain()
    }

    func verifyOTP(code: String) async throws -> AuthSession {
        let requestBody = try client.encodeBody(OTPVerificationRequest(code: code))
        let endpoint = APIEndpoint(
            path: "/auth/verify-otp",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )

        let response: AuthResponse = try await client.request(endpoint)
        return response.toDomain()
    }
}

private struct RegisterRequest: Encodable {
    let email: String
    let firstName: String
    let lastName: String
    let password: String
    let skinType: String
    let allergies: [String]

    init(draft: RegistrationDraft) {
        email = draft.email
        firstName = draft.firstName
        lastName = draft.lastName
        password = draft.password
        skinType = draft.skinType
        allergies = draft.allergies
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

private struct LoginRequest: Encodable {
    let email: String
    let password: String
}

private struct OTPVerificationRequest: Encodable {
    let code: String
}

private struct AuthResponse: Decodable {
    let userID: UUID
    let email: String
    let authToken: String
    let refreshToken: String

    func toDomain() -> AuthSession {
        AuthSession(
            userID: userID,
            email: email,
            authToken: authToken,
            refreshToken: refreshToken
        )
    }
}
