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

    func signIn(email: String, password: String) async {
        await performRequest {
            let newSession = try await authService.signIn(email: email, password: password)
            session = newSession
            try await loadAuthenticatedContent(for: newSession.userID)
        }
    }

    func completeVerification(code: String) async {
        await performRequest {
            let newSession = try await authService.verifyOTP(code: code)
            session = newSession
            try await loadAuthenticatedContent(for: newSession.userID)
        }
    }

    func analyzeBarcode(_ barcode: String) async {
        await performRequest {
            latestScanResult = try await scanService.analyzeBarcode(barcode, for: session?.userID)
        }
    }

    func signOut() {
        session = nil
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
