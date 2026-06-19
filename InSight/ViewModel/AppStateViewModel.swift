import Foundation
import Observation

enum SessionRestoreState: Equatable {
    case pending
    case restoring
    case finished
    case failed
}

enum BackendConnectionState: Equatable {
    case unchecked
    case checking
    case reachable
    case unavailable(String)
}

@Observable
final class AppStateViewModel {
    private let authService: AuthServicing
    private let profileService: ProfileServicing
    private let contentService: ContentServicing
    private let scanService: ScanServicing
    private let sessionStore: SessionPersisting
    private let healthService: HealthServicing

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
    var sessionRestoreState: SessionRestoreState
    var backendConnectionState: BackendConnectionState = .unchecked

    init(
        authService: AuthServicing = MockAuthService(),
        profileService: ProfileServicing = MockProfileService(),
        contentService: ContentServicing = MockContentService(),
        scanService: ScanServicing = MockScanService(),
        healthService: HealthServicing = MockHealthService(),
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
        self.healthService = healthService
        self.sessionStore = sessionStore
        self.session = session
        self.userProfile = userProfile
        self.savedReviews = savedReviews
        self.recommendations = recommendations
        self.latestScanResult = latestScanResult
        self.sessionRestoreState = session == nil ? .finished : .pending
    }

    var isLoggedIn: Bool {
        session != nil
    }

    var displayName: String {
        userProfile?.fullName ?? registrationDraft.fullName ?? String(localized: "Profile")
    }

    var firstName: String {
        userProfile?.firstName ?? registrationDraft.firstNameIfAvailable ?? String(localized: "Profile")
    }

    var isLatestScanSaved: Bool {
        guard let latestScanResult else { return false }
        return savedReviews.contains { review in
            review.productID == latestScanResult.product.id
        }
    }

    var isRestoringSession: Bool {
        sessionRestoreState == .pending || sessionRestoreState == .restoring
    }

    var backendConnectivityMessage: String? {
        if case let .unavailable(message) = backendConnectionState {
            return message
        }

        return nil
    }

    func bootstrap() async {
        await restoreSession()
        await checkBackendConnectivity()
    }

    func checkBackendConnectivity() async {
        backendConnectionState = .checking

        do {
            try await healthService.checkHealth()
            backendConnectionState = .reachable
        } catch {
            backendConnectionState = .unavailable(
                String(localized: "Backend is not reachable. Check your connection or API base URL.")
            )
        }
    }

    func updateRegistrationDraft(_ draft: RegistrationDraft) {
        registrationDraft = draft
    }

    func prepareForNewScan() {
        latestScanResult = nil
        errorMessage = nil
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

    func requestEmailChangeCurrentCode(newEmail: String) async {
        await performAuthenticatedRequest { session in
            try await authService.requestEmailChangeCurrentCode(newEmail: newEmail, session: session)
        }
    }

    func verifyEmailChangeCurrentCode(_ code: String) async {
        await performAuthenticatedRequest { session in
            try await authService.verifyEmailChangeCurrentCode(code: code, session: session)
        }
    }

    func confirmEmailChangeNewCode(_ code: String) async {
        await performAuthenticatedRequest { activeSession in
            let newEmail = try await authService.confirmEmailChangeNewCode(code: code, session: activeSession)
            let updatedSession = AuthSession(
                userID: activeSession.userID,
                email: newEmail,
                authToken: activeSession.authToken,
                refreshToken: activeSession.refreshToken
            )

            session = updatedSession
            sessionStore.saveSession(updatedSession)

            if var userProfile {
                userProfile.email = newEmail
                self.userProfile = userProfile
            }
        }
    }

    func reloadProfile() async {
        await performAuthenticatedRequest { session in
            userProfile = try await profileService.fetchUserProfile(
                userID: session.userID,
                authToken: session.authToken
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
        sessionRestoreState = .finished
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

        guard let storedSession = session ?? sessionStore.loadSession() else {
            sessionRestoreState = .finished
            return
        }

        sessionRestoreState = .restoring
        session = storedSession

        do {
            try await loadAuthenticatedContent(for: storedSession)
            sessionRestoreState = .finished
        } catch {
            if isUnauthorized(error) {
                do {
                    let refreshedSession = try await authService.refresh(session: storedSession)
                    session = refreshedSession
                    sessionStore.saveSession(refreshedSession)
                    try await loadAuthenticatedContent(for: refreshedSession)
                    sessionRestoreState = .finished
                    return
                } catch {
                    if isUnauthorized(error) {
                        sessionStore.clearSession()
                        session = nil
                    }
                }
            }

            userProfile = nil
            savedReviews = []
            recommendations = []
            latestScanResult = nil
            sessionRestoreState = .failed
            errorMessage = error.localizedDescription
        }
    }

    private func loadAuthenticatedContent(for session: AuthSession) async throws {
        let userID = session.userID
        let authToken = session.authToken

        userProfile = try await profileService.fetchUserProfile(userID: userID, authToken: authToken)

        do {
            savedReviews = try await contentService.fetchSavedReviews(for: userID, authToken: authToken)
        } catch {
            savedReviews = []
        }

        do {
            self.recommendations = try await contentService.fetchRecommendations(for: userID, authToken: authToken)
        } catch {
            self.recommendations = []
        }
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
