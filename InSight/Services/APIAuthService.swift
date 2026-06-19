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

    func verifyOTP(email: String, code: String) async throws -> AuthSession {
        let requestBody = try client.encodeBody(OTPVerificationRequest(email: email, code: code))
        let endpoint = APIEndpoint(
            path: "/auth/verify-otp",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )

        let response: AuthResponse = try await client.request(endpoint)
        return response.toDomain()
    }

    func refresh(session: AuthSession) async throws -> AuthSession {
        let requestBody = try client.encodeBody(RefreshRequest(refreshToken: session.refreshToken))
        let endpoint = APIEndpoint(
            path: "/auth/refresh",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )

        let response: AuthResponse = try await client.request(endpoint)
        return response.toDomain()
    }

    func logout(session: AuthSession) async throws {
        let requestBody = try client.encodeBody(LogoutRequest(
            authToken: session.authToken,
            refreshToken: session.refreshToken
        ))
        let endpoint = APIEndpoint(
            path: "/auth/logout",
            method: .post,
            headers: [
                "Authorization": "Bearer \(session.authToken)",
                "Content-Type": "application/json"
            ],
            body: requestBody
        )

        try await client.request(endpoint)
    }

    func requestEmailChangeCurrentCode(newEmail: String, session: AuthSession) async throws {
        let requestBody = try client.encodeBody(EmailChangeRequest(newEmail: newEmail))
        let endpoint = APIEndpoint(
            path: "/auth/email-change/request-current-code",
            method: .post,
            headers: [
                "Authorization": "Bearer \(session.authToken)",
                "Content-Type": "application/json"
            ],
            body: requestBody
        )

        try await client.request(endpoint)
    }

    func verifyEmailChangeCurrentCode(code: String, session: AuthSession) async throws {
        let requestBody = try client.encodeBody(CodeVerificationRequest(code: code))
        let endpoint = APIEndpoint(
            path: "/auth/email-change/verify-current-code",
            method: .post,
            headers: [
                "Authorization": "Bearer \(session.authToken)",
                "Content-Type": "application/json"
            ],
            body: requestBody
        )

        try await client.request(endpoint)
    }

    func confirmEmailChangeNewCode(code: String, session: AuthSession) async throws -> String {
        let requestBody = try client.encodeBody(CodeVerificationRequest(code: code))
        let endpoint = APIEndpoint(
            path: "/auth/email-change/confirm-new-code",
            method: .post,
            headers: [
                "Authorization": "Bearer \(session.authToken)",
                "Content-Type": "application/json"
            ],
            body: requestBody
        )

        let response: EmailChangeResponse = try await client.request(endpoint)
        return response.email
    }
}

private struct RegisterRequest: Encodable {
    let email: String
    let firstName: String
    let lastName: String
    let password: String
    let age: Int
    let gender: String
    let skinType: String
    let allergies: [String]

    init(draft: RegistrationDraft) {
        email = draft.email
        firstName = draft.firstName
        lastName = draft.lastName
        password = draft.password
        age = draft.age
        gender = draft.gender.apiGenderValue
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
    let email: String
    let code: String
}

private struct LogoutRequest: Encodable {
    let authToken: String
    let refreshToken: String
}

private struct RefreshRequest: Encodable {
    let refreshToken: String
}

private struct EmailChangeRequest: Encodable {
    let newEmail: String
}

private struct CodeVerificationRequest: Encodable {
    let code: String
}

private struct EmailChangeResponse: Decodable {
    let email: String
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

private extension String {
    var apiGenderValue: String {
        switch trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "female":
            return "female"
        case "male":
            return "male"
        case "non-binary", "non binary", "other":
            return "other"
        default:
            return self
        }
    }
}
