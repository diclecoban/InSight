import Foundation
import Observation

@Observable
final class AppStateViewModel {
    private let authService: AuthServicing
    private let profileService: ProfileServicing
    private let contentService: ContentServicing
    private let scanService: ScanServicing

    var session: AuthSession?
    var userProfile: UserProfile?
    var savedReviews: [SavedReview]
    var recommendations: [RecommendationItem]
    var latestScanResult: ScanResult?
    var registrationDraft = RegistrationDraft()
    var didCompleteRegistration = false
    var isLoading = false
    var errorMessage: String?

    init(
        authService: AuthServicing = MockAuthService(),
        profileService: ProfileServicing = MockProfileService(),
        contentService: ContentServicing = MockContentService(),
        scanService: ScanServicing = MockScanService(),
        session: AuthSession? = nil,
        userProfile: UserProfile? = AppMockData.profile,
        savedReviews: [SavedReview] = AppMockData.savedReviews,
        recommendations: [RecommendationItem] = AppMockData.recommendations,
        latestScanResult: ScanResult? = AppMockData.sampleScanResult
    ) {
        self.authService = authService
        self.profileService = profileService
        self.contentService = contentService
        self.scanService = scanService
        self.session = session
        self.userProfile = userProfile
        self.savedReviews = savedReviews
        self.recommendations = recommendations
        self.latestScanResult = latestScanResult
    }

    var isLoggedIn: Bool {
        session != nil
    }

    var displayName: String {
        userProfile?.fullName ?? "Guest User"
    }

    var firstName: String {
        userProfile?.firstName ?? "Guest"
    }

    var isLatestScanSaved: Bool {
        guard let latestScanResult else { return false }
        return savedReviews.contains { review in
            review.productName == latestScanResult.product.name
        }
    }

    func updateRegistrationDraft(_ draft: RegistrationDraft) {
        registrationDraft = draft
    }

    func register() async {
        await performRequest {
            try await authService.register(draft: registrationDraft)
            didCompleteRegistration = true
        }
    }

    func signIn(email: String, password: String) async {
        await performRequest {
            let newSession = try await authService.signIn(email: email, password: password)
            session = newSession
            try await loadAuthenticatedContent(for: newSession.userID)
        }
    }

    func completeVerification(code: String) async {
        await performRequest {
            let newSession = try await authService.verifyOTP(
                email: registrationDraft.email,
                code: code
            )
            session = newSession
            try await loadAuthenticatedContent(for: newSession.userID)
        }
    }

    func analyzeBarcode(_ barcode: String) async {
        await performRequest {
            latestScanResult = try await scanService.analyzeBarcode(barcode, for: session?.userID)
        }
    }

    func saveLatestScanResult() async {
        await performRequest {
            guard let userID = session?.userID else {
                throw AppServiceError.missingSession
            }
            guard let latestScanResult else {
                throw AppServiceError.unsupportedBarcode
            }

            try await contentService.saveReview(
                productID: latestScanResult.product.id,
                status: latestScanResult.safetyLevel,
                for: userID
            )
            savedReviews = try await contentService.fetchSavedReviews(for: userID)
        }
    }

    func deleteSavedReview(_ review: SavedReview) async {
        await performRequest {
            guard let userID = session?.userID else {
                throw AppServiceError.missingSession
            }

            try await contentService.deleteSavedReview(reviewID: review.id, for: userID)
            savedReviews.removeAll { $0.id == review.id }
        }
    }

    func updateProfile(draft: ProfileUpdateDraft) async {
        await performRequest {
            guard let userID = session?.userID else {
                throw AppServiceError.missingSession
            }

            userProfile = try await profileService.updateUserProfile(
                userID: userID,
                draft: draft
            )
        }
    }

    func signOut() {
        let sessionToLogout = session

        session = nil
        userProfile = nil
        savedReviews = []
        recommendations = []
        latestScanResult = nil
        errorMessage = nil

        if let sessionToLogout {
            Task {
                try? await authService.logout(session: sessionToLogout)
            }
        }
    }

    func resetRegistrationFlow() {
        didCompleteRegistration = false
        errorMessage = nil
    }

    private func loadAuthenticatedContent(for userID: UUID) async throws {
        async let profile = profileService.fetchUserProfile(userID: userID)
        async let reviews = contentService.fetchSavedReviews(for: userID)
        async let recommendations = contentService.fetchRecommendations(for: userID)

        userProfile = try await profile
        savedReviews = try await reviews
        self.recommendations = try await recommendations
    }

    private func performRequest(_ operation: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil

        do {
            try await operation()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
