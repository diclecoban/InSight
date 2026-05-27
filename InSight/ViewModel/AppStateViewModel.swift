import Foundation
import Observation

@Observable
final class AppStateViewModel {
    private let authService: AuthServicing
    private let profileService: ProfileServicing
    private let contentService: ContentServicing
    private let scanService: ScanServicing
    private let sessionStore: SessionPersisting

    var session: AuthSession?
    var userProfile: UserProfile?
    var savedReviews: [SavedReview]
    var recommendations: [RecommendationItem]
    var latestScanResult: ScanResult?
    var registrationDraft = RegistrationDraft()
    var didCompleteRegistration = false
    var didRestoreSession = false
    var isLoading = false
    var errorMessage: String?

    init(
        authService: AuthServicing = MockAuthService(),
        profileService: ProfileServicing = MockProfileService(),
        contentService: ContentServicing = MockContentService(),
        scanService: ScanServicing = MockScanService(),
        sessionStore: SessionPersisting = InMemorySessionStore(),
        session: AuthSession? = nil,
        userProfile: UserProfile? = nil,
        savedReviews: [SavedReview] = [],
        recommendations: [RecommendationItem] = [],
        latestScanResult: ScanResult? = nil
    ) {
        self.authService = authService
        self.profileService = profileService
        self.contentService = contentService
        self.scanService = scanService
        self.sessionStore = sessionStore
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
            sessionStore.saveSession(newSession)
            try await loadAuthenticatedContent(for: newSession)
        }
    }

    func completeVerification(code: String) async {
        await performRequest {
            let newSession = try await authService.verifyOTP(
                email: registrationDraft.email,
                code: code
            )
            session = newSession
            sessionStore.saveSession(newSession)
            try await loadAuthenticatedContent(for: newSession)
        }
    }

    func analyzeBarcode(_ barcode: String) async {
        if session == nil {
            await performRequest {
                latestScanResult = try await scanService.analyzeBarcode(barcode, for: nil)
            }
        } else {
            await performAuthenticatedRequest { session in
                latestScanResult = try await scanService.analyzeBarcode(barcode, for: session)
            }
        }
    }

    func saveLatestScanResult() async {
        await performAuthenticatedRequest { session in
            let userID = session.userID
            guard let latestScanResult else {
                throw AppServiceError.unsupportedBarcode
            }

            try await contentService.saveReview(
                productID: latestScanResult.product.id,
                status: latestScanResult.safetyLevel,
                for: userID,
                authToken: session.authToken
            )
            savedReviews = try await contentService.fetchSavedReviews(
                for: userID,
                authToken: session.authToken
            )
        }
    }

    func deleteSavedReview(_ review: SavedReview) async {
        await performAuthenticatedRequest { session in
            let userID = session.userID

            try await contentService.deleteSavedReview(
                reviewID: review.id,
                for: userID,
                authToken: session.authToken
            )
            savedReviews.removeAll { $0.id == review.id }
        }
    }

    func updateProfile(draft: ProfileUpdateDraft) async {
        await performAuthenticatedRequest { session in
            let userID = session.userID

            userProfile = try await profileService.updateUserProfile(
                userID: userID,
                authToken: session.authToken,
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
        sessionStore.clearSession()

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

    func restoreSession() async {
        guard !didRestoreSession else { return }
        didRestoreSession = true

        guard let storedSession = sessionStore.loadSession() else { return }
        session = storedSession

        await performAuthenticatedRequest { session in
            try await loadAuthenticatedContent(for: session)
        }
    }

    private func loadAuthenticatedContent(for session: AuthSession) async throws {
        let userID = session.userID
        let authToken = session.authToken

        async let profile = profileService.fetchUserProfile(userID: userID, authToken: authToken)
        async let reviews = contentService.fetchSavedReviews(for: userID, authToken: authToken)
        async let recommendations = contentService.fetchRecommendations(for: userID, authToken: authToken)

        userProfile = try await profile
        savedReviews = try await reviews
        self.recommendations = try await recommendations
    }

    private func performAuthenticatedRequest(_ operation: (AuthSession) async throws -> Void) async {
        await performRequest {
            guard var activeSession = session else {
                throw AppServiceError.missingSession
            }

            do {
                try await operation(activeSession)
            } catch {
                guard isUnauthorized(error) else {
                    throw error
                }

                do {
                    activeSession = try await authService.refresh(session: activeSession)
                } catch {
                    if isUnauthorized(error) {
                        session = nil
                        userProfile = nil
                        savedReviews = []
                        recommendations = []
                        latestScanResult = nil
                        sessionStore.clearSession()
                    }

                    throw error
                }

                session = activeSession
                sessionStore.saveSession(activeSession)
                try await operation(activeSession)
            }
        }
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

    private func isUnauthorized(_ error: Error) -> Bool {
        (error as? APIClientError)?.isUnauthorized ?? false
    }
}
