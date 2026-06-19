

import Foundation

protocol AuthServicing {
    func register(draft: RegistrationDraft) async throws
    func signIn(email: String, password: String) async throws -> AuthSession
    func verifyOTP(email: String, code: String) async throws -> AuthSession
    func refresh(session: AuthSession) async throws -> AuthSession
    func logout(session: AuthSession) async throws
    func requestEmailChangeCurrentCode(newEmail: String, session: AuthSession) async throws
    func verifyEmailChangeCurrentCode(code: String, session: AuthSession) async throws
    func confirmEmailChangeNewCode(code: String, session: AuthSession) async throws -> String
}

protocol SessionPersisting {
    func loadSession() -> AuthSession?
    func saveSession(_ session: AuthSession)
    func clearSession()
}

protocol ProfileServicing {
    func fetchUserProfile(userID: UUID, authToken: String) async throws -> UserProfile
    func updateUserProfile(userID: UUID, authToken: String, draft: ProfileUpdateDraft) async throws -> UserProfile
}

protocol ContentServicing {
    func fetchSavedReviews(for userID: UUID, authToken: String) async throws -> [SavedReview]
    func fetchRecommendations(for userID: UUID, authToken: String) async throws -> [RecommendationItem]
    func saveReview(productID: UUID, status: SafetyLevel, for userID: UUID, authToken: String) async throws
    func deleteSavedReview(reviewID: UUID, for userID: UUID, authToken: String) async throws
}

protocol ScanServicing {
    func analyzeBarcode(_ barcode: String, for session: AuthSession?) async throws -> ScanResult
}

protocol HealthServicing {
    func checkHealth() async throws
}

enum AppServiceError: LocalizedError {
    case invalidRegistration
    case invalidCredentials
    case invalidOTP
    case missingSession
    case unsupportedBarcode
    case backendUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidRegistration:
            return String(localized: "Registration details are missing or invalid.")
        case .invalidCredentials:
            return String(localized: "Email or password is incorrect.")
        case .invalidOTP:
            return String(localized: "The OTP code is invalid.")
        case .missingSession:
            return String(localized: "No session found.")
        case .unsupportedBarcode:
            return String(localized: "No result was found for this barcode.")
        case .backendUnavailable:
            return String(localized: "Backend is not reachable right now.")
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
        gender: "female",
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
        SavedReview(id: UUID(), productID: UUID(), productName: "Hydrating Cleanser", brand: "CeraVe", imageURL: nil, barcode: "3337875597180", status: .mostlySafe, savedAt: .now),
        SavedReview(id: UUID(), productID: UUID(), productName: "Vitamin C Serum", brand: "La Roche-Posay", imageURL: nil, barcode: "3337875660570", status: .safe, savedAt: .now),
        SavedReview(id: UUID(), productID: UUID(), productName: "Fragrance Mist", brand: "Demo Brand", imageURL: nil, barcode: "8691234567890", status: .risky, savedAt: .now)
    ]

    static let sampleScanResult = ScanResult(
        id: UUID(),
        product: Product(
            id: UUID(),
            name: "CERAVE Cleanser",
            brand: "CeraVe",
            priceText: "$19.99",
            imageURL: nil,
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
                riskNote: "Low risk for most skin types.",
                riskLevel: "low"
            ),
            IngredientInsight(
                id: UUID(),
                name: "Fragrance",
                detail: "Used to adjust the scent profile.",
                riskNote: "Can trigger irritation in sensitive skin.",
                riskLevel: "high"
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

    func refresh(session: AuthSession) async throws -> AuthSession {
        try await Task.sleep(for: .milliseconds(250))
        return session
    }

    func logout(session: AuthSession) async throws {
        try await Task.sleep(for: .milliseconds(150))
    }

    func requestEmailChangeCurrentCode(newEmail: String, session: AuthSession) async throws {
        try await Task.sleep(for: .milliseconds(250))
    }

    func verifyEmailChangeCurrentCode(code: String, session: AuthSession) async throws {
        try await Task.sleep(for: .milliseconds(250))
    }

    func confirmEmailChangeNewCode(code: String, session: AuthSession) async throws -> String {
        try await Task.sleep(for: .milliseconds(250))
        return session.email
    }
}

struct InMemorySessionStore: SessionPersisting {
    func loadSession() -> AuthSession? {
        nil
    }

    func saveSession(_ session: AuthSession) {}

    func clearSession() {}
}

struct MockProfileService: ProfileServicing {
    func fetchUserProfile(userID: UUID, authToken: String) async throws -> UserProfile {
        try await Task.sleep(for: .milliseconds(300))
        return AppMockData.profile
    }

    func updateUserProfile(userID: UUID, authToken: String, draft: ProfileUpdateDraft) async throws -> UserProfile {
        try await Task.sleep(for: .milliseconds(300))

        return UserProfile(
            id: userID,
            firstName: draft.firstName,
            lastName: draft.lastName,
            email: AppMockData.profile.email,
            age: AppMockData.profile.age,
            gender: draft.gender,
            skinType: draft.skinType,
            condition: draft.condition,
            sensitivity: draft.sensitivity,
            allergies: draft.allergies
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )
    }
}

struct MockContentService: ContentServicing {
    func fetchSavedReviews(for userID: UUID, authToken: String) async throws -> [SavedReview] {
        try await Task.sleep(for: .milliseconds(250))
        return AppMockData.savedReviews
    }

    func fetchRecommendations(for userID: UUID, authToken: String) async throws -> [RecommendationItem] {
        try await Task.sleep(for: .milliseconds(250))
        return AppMockData.recommendations
    }

    func saveReview(productID: UUID, status: SafetyLevel, for userID: UUID, authToken: String) async throws {
        try await Task.sleep(for: .milliseconds(250))
    }

    func deleteSavedReview(reviewID: UUID, for userID: UUID, authToken: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }
}

struct MockScanService: ScanServicing {
    func analyzeBarcode(_ barcode: String, for session: AuthSession?) async throws -> ScanResult {
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
            imageURL: nil,
            barcode: barcode
        )
        result.scannedAt = .now
        return result
    }
}

struct MockHealthService: HealthServicing {
    func checkHealth() async throws {
        try await Task.sleep(for: .milliseconds(150))
    }
}
