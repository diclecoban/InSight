import Foundation

struct APIProfileService: ProfileServicing {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchUserProfile(userID: UUID, authToken: String) async throws -> UserProfile {
        let endpoint = APIEndpoint(
            path: "/profiles/\(userID.uuidString)",
            headers: APIHeaders.authorized(authToken)
        )
        let response: UserProfileResponse = try await client.request(endpoint)
        return response.toDomain()
    }

    func updateUserProfile(userID: UUID, authToken: String, draft: ProfileUpdateDraft) async throws -> UserProfile {
        let requestBody = try client.encodeBody(ProfileUpdateRequest(draft: draft))
        let endpoint = APIEndpoint(
            path: "/profiles/\(userID.uuidString)",
            method: .patch,
            headers: APIHeaders.jsonAuthorized(authToken),
            body: requestBody
        )

        let response: UserProfileResponse = try await client.request(endpoint)
        return response.toDomain()
    }
}

struct APIContentService: ContentServicing {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchSavedReviews(for userID: UUID, authToken: String) async throws -> [SavedReview] {
        let endpoint = APIEndpoint(
            path: "/content/\(userID.uuidString)/saved-reviews",
            headers: APIHeaders.authorized(authToken)
        )
        let response: [SavedReviewResponse] = try await client.request(endpoint)
        return response.map { $0.toDomain() }
    }

    func fetchRecommendations(for userID: UUID, authToken: String) async throws -> [RecommendationItem] {
        let endpoint = APIEndpoint(
            path: "/content/\(userID.uuidString)/recommendations",
            headers: APIHeaders.authorized(authToken)
        )
        let response: [RecommendationResponse] = try await client.request(endpoint)
        return response.map { $0.toDomain() }
    }

    func saveReview(productID: UUID, status: SafetyLevel, for userID: UUID, authToken: String) async throws {
        let requestBody = try client.encodeBody(SaveReviewRequest(
            productID: productID,
            status: status.rawValue
        ))
        let endpoint = APIEndpoint(
            path: "/content/\(userID.uuidString)/saved-reviews",
            method: .post,
            headers: APIHeaders.jsonAuthorized(authToken),
            body: requestBody
        )

        try await client.request(endpoint)
    }

    func deleteSavedReview(reviewID: UUID, for userID: UUID, authToken: String) async throws {
        let endpoint = APIEndpoint(
            path: "/content/\(userID.uuidString)/saved-reviews/\(reviewID.uuidString)",
            method: .delete,
            headers: APIHeaders.authorized(authToken)
        )

        try await client.request(endpoint)
    }
}

struct APIScanService: ScanServicing {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func analyzeBarcode(_ barcode: String, for session: AuthSession?) async throws -> ScanResult {
        let requestBody = try client.encodeBody(ScanRequest(
            barcode: barcode,
            userID: session?.userID
        ))
        let endpoint = APIEndpoint(
            path: "/scan/analyze",
            method: .post,
            headers: APIHeaders.scan(session?.authToken),
            body: requestBody
        )

        let response: ScanResultResponse = try await client.request(endpoint)
        return response.toDomain()
    }
}

struct APIHealthService: HealthServicing {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func checkHealth() async throws {
        let endpoint = APIEndpoint(
            path: "/health",
            headers: [
                "Accept": "application/json",
                "X-Client-Platform": "ios",
                "X-Client-Version": NetworkConfiguration.clientVersion,
                "Accept-Language": Locale.preferredLanguages.first ?? "en"
            ]
        )
        let response: HealthResponse = try await client.request(endpoint)

        guard response.status == "ok" else {
            throw AppServiceError.backendUnavailable
        }
    }
}

private enum APIHeaders {
    static func authorized(_ token: String) -> [String: String] {
        [
            "Authorization": "Bearer \(token)",
            "X-Client-Platform": "ios",
            "X-Client-Version": NetworkConfiguration.clientVersion,
            "Accept-Language": Locale.preferredLanguages.first ?? "en"
        ]
    }

    static func jsonAuthorized(_ token: String) -> [String: String] {
        authorized(token).merging(["Content-Type": "application/json"]) { _, new in new }
    }

    static func scan(_ token: String?) -> [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "X-Client-Platform": "ios",
            "X-Client-Version": NetworkConfiguration.clientVersion,
            "X-Scan-Source": "barcode",
            "Accept-Language": Locale.preferredLanguages.first ?? "en"
        ]

        if let token {
            headers["Authorization"] = "Bearer \(token)"
        }

        return headers
    }
}

private struct HealthResponse: Decodable {
    let status: String
}

private struct UserProfileResponse: Decodable {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let age: Int
    let gender: String
    let skinType: String
    let condition: String
    let sensitivity: String
    let allergies: [String]

    func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            age: age,
            gender: gender,
            skinType: skinType,
            condition: condition,
            sensitivity: sensitivity,
            allergies: allergies
        )
    }
}

private struct ProfileUpdateRequest: Encodable {
    let firstName: String
    let lastName: String
    let age: Int
    let gender: String
    let skinType: String
    let condition: String
    let sensitivity: String
    let allergies: [String]

    init(draft: ProfileUpdateDraft) {
        firstName = draft.firstName
        lastName = draft.lastName
        age = draft.age
        gender = draft.gender.apiGenderValue
        skinType = draft.skinType
        condition = draft.condition
        sensitivity = draft.sensitivity
        allergies = draft.allergies
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

private struct SavedReviewResponse: Decodable {
    let id: UUID
    let productID: UUID
    let productName: String
    let brand: String
    let imageURL: URL?
    let barcode: String
    let status: SafetyLevelResponse
    let savedAt: Date

    func toDomain() -> SavedReview {
        SavedReview(
            id: id,
            productID: productID,
            productName: productName,
            brand: brand,
            imageURL: imageURL,
            barcode: barcode,
            status: status.toDomain(),
            savedAt: savedAt
        )
    }
}

private struct RecommendationResponse: Decodable {
    let id: UUID
    let title: String
    let subtitle: String

    func toDomain() -> RecommendationItem {
        RecommendationItem(id: id, title: title, subtitle: subtitle)
    }
}

private struct SaveReviewRequest: Encodable {
    let productID: UUID
    let status: String
}

private struct ScanRequest: Encodable {
    let barcode: String
    let userID: UUID?
}

private struct ScanResultResponse: Decodable {
    let id: UUID
    let product: ProductResponse
    let score: Double
    let safetyLevel: SafetyLevelResponse
    let summary: String
    let ingredients: [IngredientInsightResponse]
    let scannedAt: Date

    func toDomain() -> ScanResult {
        ScanResult(
            id: id,
            product: product.toDomain(),
            score: score,
            safetyLevel: safetyLevel.toDomain(),
            summary: summary,
            ingredients: ingredients.map { $0.toDomain() },
            scannedAt: scannedAt
        )
    }
}

private struct ProductResponse: Decodable {
    let id: UUID
    let name: String
    let brand: String
    let priceText: String
    let imageURL: URL?
    let barcode: String

    func toDomain() -> Product {
        Product(
            id: id,
            name: name,
            brand: brand,
            priceText: priceText,
            imageURL: imageURL,
            barcode: barcode
        )
    }
}

private struct IngredientInsightResponse: Decodable {
    let id: UUID
    let name: String
    let detail: String
    let riskNote: String
    let riskLevel: String

    func toDomain() -> IngredientInsight {
        IngredientInsight(
            id: id,
            name: name,
            detail: detail,
            riskNote: riskNote,
            riskLevel: riskLevel
        )
    }
}

private enum SafetyLevelResponse: String, Decodable {
    case safe
    case mostlySafe
    case risky

    func toDomain() -> SafetyLevel {
        switch self {
        case .safe:
            return .safe
        case .mostlySafe:
            return .mostlySafe
        case .risky:
            return .risky
        }
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
