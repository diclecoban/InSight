

import Foundation

protocol AuthServicing {
    func register(draft: RegistrationDraft) async throws
    func signIn(email: String, password: String) async throws -> AuthSession
    func verifyOTP(email: String, code: String) async throws -> AuthSession
}

protocol ProfileServicing {
    func fetchUserProfile(userID: UUID) async throws -> UserProfile
}

protocol ContentServicing {
    func fetchSavedReviews(for userID: UUID) async throws -> [SavedReview]
    func fetchRecommendations(for userID: UUID) async throws -> [RecommendationItem]
}

protocol ScanServicing {
    func analyzeBarcode(_ barcode: String, for userID: UUID?) async throws -> ScanResult
}

enum AppServiceError: LocalizedError {
    case invalidRegistration
    case invalidCredentials
    case invalidOTP
    case missingSession
    case unsupportedBarcode

    var errorDescription: String? {
        switch self {
        case .invalidRegistration:
            return "Kayit bilgileri eksik veya gecersiz."
        case .invalidCredentials:
            return "Email veya password hatali."
        case .invalidOTP:
            return "OTP kodu gecersiz."
        case .missingSession:
            return "Oturum bulunamadi."
        case .unsupportedBarcode:
            return "Bu barkod icin sonuc bulunamadi."
        }
    }
}

enum AppMockData {
    static let profile = UserProfile(
        id: UUID(),
        firstName: "Susan",
        lastName: "Clay",
        email: "susan@insight.app",
        age: 19,
        skinType: "Dry",
        condition: "Sensitive Skin",
        sensitivity: "High",
        allergies: ["Fragrance"]
    )

    static let recommendations = [
        RecommendationItem(id: UUID(), title: "Ingredient of the Day", subtitle: "It is you"),
        RecommendationItem(id: UUID(), title: "Why Avoid Palm Oil?", subtitle: "Rosaville")
    ]

    static let savedReviews = [
        SavedReview(id: UUID(), productName: "Hydrating Cleanser", status: .mostlySafe, savedAt: .now),
        SavedReview(id: UUID(), productName: "Vitamin C Serum", status: .safe, savedAt: .now),
        SavedReview(id: UUID(), productName: "Fragrance Mist", status: .risky, savedAt: .now)
    ]

    static let sampleScanResult = ScanResult(
        id: UUID(),
        product: Product(
            id: UUID(),
            name: "CERAVE Cleanser",
            brand: "CeraVe",
            priceText: "$19.99",
            barcode: "8691234567890"
        ),
        score: 0.7,
        safetyLevel: .mostlySafe,
        summary: "The product is 70% safe.",
        ingredients: [
            IngredientInsight(
                id: UUID(),
                name: "Glycerin",
                detail: "A humectant that supports hydration.",
                riskNote: "Low risk for most skin types."
            ),
            IngredientInsight(
                id: UUID(),
                name: "Fragrance",
                detail: "Used to adjust the scent profile.",
                riskNote: "Can trigger irritation in sensitive skin."
            )
        ],
        scannedAt: .now
    )
}

struct MockAuthService: AuthServicing {
    func register(draft: RegistrationDraft) async throws {
        try await Task.sleep(for: .milliseconds(600))

        guard
            !draft.email.isEmpty,
            !draft.firstName.isEmpty,
            !draft.lastName.isEmpty,
            !draft.password.isEmpty,
            !draft.gender.isEmpty,
            !draft.skinType.isEmpty
        else {
            throw AppServiceError.invalidRegistration
        }
    }

    func signIn(email: String, password: String) async throws -> AuthSession {
        try await Task.sleep(for: .milliseconds(500))

        guard !email.isEmpty, !password.isEmpty else {
            throw AppServiceError.invalidCredentials
        }

        return AuthSession(
            userID: AppMockData.profile.id,
            email: email,
            authToken: "mock-auth-token",
            refreshToken: "mock-refresh-token"
        )
    }

    func verifyOTP(email: String, code: String) async throws -> AuthSession {
        try await Task.sleep(for: .milliseconds(400))

        guard !email.isEmpty, code.count == 6 else {
            throw AppServiceError.invalidOTP
        }

        return AuthSession(
            userID: AppMockData.profile.id,
            email: AppMockData.profile.email,
            authToken: "mock-auth-token",
            refreshToken: "mock-refresh-token"
        )
    }
}

struct MockProfileService: ProfileServicing {
    func fetchUserProfile(userID: UUID) async throws -> UserProfile {
        try await Task.sleep(for: .milliseconds(300))
        return AppMockData.profile
    }
}

struct MockContentService: ContentServicing {
    func fetchSavedReviews(for userID: UUID) async throws -> [SavedReview] {
        try await Task.sleep(for: .milliseconds(250))
        return AppMockData.savedReviews
    }

    func fetchRecommendations(for userID: UUID) async throws -> [RecommendationItem] {
        try await Task.sleep(for: .milliseconds(250))
        return AppMockData.recommendations
    }
}

struct MockScanService: ScanServicing {
    func analyzeBarcode(_ barcode: String, for userID: UUID?) async throws -> ScanResult {
        try await Task.sleep(for: .milliseconds(700))

        guard !barcode.isEmpty else {
            throw AppServiceError.unsupportedBarcode
        }

        var result = AppMockData.sampleScanResult
        result.product = Product(
            id: UUID(),
            name: "Scanned Product",
            brand: "InSight Demo",
            priceText: "$19.99",
            barcode: barcode
        )
        result.scannedAt = .now
        return result
    }
}
