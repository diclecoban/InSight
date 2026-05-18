import Foundation

struct APIProfileService: ProfileServicing {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchUserProfile(userID: UUID) async throws -> UserProfile {
        let endpoint = APIEndpoint(path: "/profiles/\(userID.uuidString)")
        let response: UserProfileResponse = try await client.request(endpoint)
        return response.toDomain()
    }

    func updateUserProfile(userID: UUID, draft: ProfileUpdateDraft) async throws -> UserProfile {
        let requestBody = try client.encodeBody(ProfileUpdateRequest(draft: draft))
        let endpoint = APIEndpoint(
            path: "/profiles/\(userID.uuidString)",
            method: .patch,
            headers: ["Content-Type": "application/json"],
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

    func fetchSavedReviews(for userID: UUID) async throws -> [SavedReview] {
        let endpoint = APIEndpoint(path: "/content/\(userID.uuidString)/saved-reviews")
        let response: [SavedReviewResponse] = try await client.request(endpoint)
        return response.map { $0.toDomain() }
    }

    func fetchRecommendations(for userID: UUID) async throws -> [RecommendationItem] {
        let endpoint = APIEndpoint(path: "/content/\(userID.uuidString)/recommendations")
        let response: [RecommendationResponse] = try await client.request(endpoint)
        return response.map { $0.toDomain() }
    }

    func saveReview(productID: UUID, status: SafetyLevel, for userID: UUID) async throws {
        let requestBody = try client.encodeBody(SaveReviewRequest(
            productID: productID,
            status: status.rawValue
        ))
        let endpoint = APIEndpoint(
            path: "/content/\(userID.uuidString)/saved-reviews",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )

        try await client.request(endpoint)
    }

    func deleteSavedReview(reviewID: UUID, for userID: UUID) async throws {
        let endpoint = APIEndpoint(
            path: "/content/\(userID.uuidString)/saved-reviews/\(reviewID.uuidString)",
            method: .delete
        )

        try await client.request(endpoint)
    }
}

struct APIScanService: ScanServicing {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func analyzeBarcode(_ barcode: String, for userID: UUID?) async throws -> ScanResult {
        let requestBody = try client.encodeBody(ScanRequest(barcode: barcode, userID: userID))
        let endpoint = APIEndpoint(
            path: "/scan/analyze",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )

        let response: ScanResultResponse = try await client.request(endpoint)
        return response.toDomain()
    }
}

private struct UserProfileResponse: Decodable {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let age: Int
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
    let skinType: String
    let condition: String
    let sensitivity: String
    let allergies: [String]

    init(draft: ProfileUpdateDraft) {
        firstName = draft.firstName
        lastName = draft.lastName
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
    let productName: String
    let status: SafetyLevelResponse
    let savedAt: Date

    func toDomain() -> SavedReview {
        SavedReview(
            id: id,
            productName: productName,
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
    let barcode: String

    func toDomain() -> Product {
        Product(
            id: id,
            name: name,
            brand: brand,
            priceText: priceText,
            barcode: barcode
        )
    }
}

private struct IngredientInsightResponse: Decodable {
    let id: UUID
    let name: String
    let detail: String
    let riskNote: String

    func toDomain() -> IngredientInsight {
        IngredientInsight(
            id: id,
            name: name,
            detail: detail,
            riskNote: riskNote
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
